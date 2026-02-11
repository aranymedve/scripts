#!/usr/bin/env bash
set -euo pipefail

# Fedora + default Btrfs layout
# Enables: snapper, grub-btrfs, automatic snapshots for dnf, grub menu entries
# Safe, idempotent; supports UEFI/BIOS; provides fallback when dnf plugin not available.

# ---------- Helpers ----------
log()  { echo -e "\e[1;32m[INFO]\e[0m $*"; }
warn() { echo -e "\e[1;33m[WARN]\e[0m $*"; }
err()  { echo -e "\e[1;31m[ERROR]\e[0m $*" >&2; }
die()  { err "$*"; exit 1; }
need() { command -v "$1" >/dev/null 2>&1 || die "Missing required command: $1"; }

need btrfs
need grub2-mkconfig || true
need lsblk
need awk
need sed
need tee
need systemctl
need dnf
need snapper || true

DATESTAMP="$(date +%Y%m%d-%H%M%S)"

# ---------- Sanity checks ----------
[ "$(id -u)" -eq 0 ] || die "Please run as root."

# Root must be btrfs
FSTYPE="$(findmnt -no FSTYPE /)"
[ "$FSTYPE" = "btrfs" ] || die "Root filesystem is '$FSTYPE', not btrfs."

# Detect boot environment
is_uefi=false
[ -d /sys/firmware/efi ] && is_uefi=true

if $is_uefi; then
  GRUB_CFG="/boot/efi/EFI/fedora/grub.cfg"
  GRUB_DIR="/boot/grub2"            # grub-btrfs usually places grub-btrfs.cfg here
else
  GRUB_CFG="/boot/grub2/grub.cfg"
  GRUB_DIR="/boot/grub2"
fi

log "Boot mode: $([ "$is_uefi" = true ] && echo UEFI || echo BIOS/Legacy)"
log "Target GRUB config: $GRUB_CFG"
log "GRUB directory: $GRUB_DIR"

# ---------- Install required packages ----------
log "Installing required packages (snapper, grub-btrfs, helpers)..."
dnf -y install \
  snapper \
  grub-btrfs \
  snapper-support \
  cronie \
  python3-dnf-plugin-post-transaction-actions || true

# Try to install the DNF snapper plugin (name varies across Fedora releases)
if dnf info python3-dnf-plugin-snapper >/dev/null 2>&1; then
  log "Installing python3-dnf-plugin-snapper..."
  dnf -y install python3-dnf-plugin-snapper || warn "Could not install python3-dnf-plugin-snapper."
elif dnf info dnf-plugin-snapper >/dev/null 2>&1; then
  log "Installing dnf-plugin-snapper..."
  dnf -y install dnf-plugin-snapper || warn "Could not install dnf-plugin-snapper."
else
  warn "DNF snapper plugin not found in repos for this Fedora. Will configure a safe wrapper fallback."
fi

# ---------- Create snapper config for root ----------
if [ ! -f /etc/snapper/configs/root ]; then
  log "Creating snapper config for / ..."
  snapper -c root create-config /
else
  log "Snapper config for root already exists. Skipping create-config."
fi

# Ensure .snapshots is mounted (snapper creates it as a subvolume)
if ! mountpoint -q /.snapshots; then
  log "Ensuring /.snapshots is properly mounted..."
  # snapper should already have updated fstab; ensure mount
  mkdir -p /.snapshots
  mount /.snapshots || true
fi

# ---------- Configure snapper retention ----------
log "Configuring snapper retention and timeline (reasonable defaults)..."
SN_CONF="/etc/snapper/configs/root"
cp -a "$SN_CONF" "${SN_CONF}.bak.${DATESTAMP}"

# Keep timeline enabled (optional); adjust limits as desired
sed -i \
  -e 's/^TIMELINE_CREATE=.*/TIMELINE_CREATE="yes"/' \
  -e 's/^TIMELINE_CLEANUP=.*/TIMELINE_CLEANUP="yes"/' \
  -e 's/^TIMELINE_MIN_AGE=.*/TIMELINE_MIN_AGE="1800"/' \
  -e 's/^TIMELINE_LIMIT_HOURLY=.*/TIMELINE_LIMIT_HOURLY="5"/' \
  -e 's/^TIMELINE_LIMIT_DAILY=.*/TIMELINE_LIMIT_DAILY="7"/' \
  -e 's/^TIMELINE_LIMIT_WEEKLY=.*/TIMELINE_LIMIT_WEEKLY="4"/' \
  -e 's/^TIMELINE_LIMIT_MONTHLY=.*/TIMELINE_LIMIT_MONTHLY="6"/' \
  -e 's/^TIMELINE_LIMIT_YEARLY=.*/TIMELINE_LIMIT_YEARLY="3"/' \
  "$SN_CONF" || true

# Enable timeline timer (hourly)
systemctl enable --now snapper-timeline.timer || true
systemctl enable --now snapper-cleanup.timer || true

# ---------- Configure automatic snapshots on DNF operations ----------
AUTOSNAP_OK=false

# Path 1: official DNF plugin (if present)
if [ -f /usr/lib/python3.*/site-packages/dnf-plugins/snapper.py ] || \
   [ -f /usr/lib/python3.*/site-packages/dnf-plugins/snapper.pyc ] || \
   [ -f /usr/lib/python3.*/site-packages/dnf-plugins/snapper/__init__.py ]; then
  log "Detected DNF snapper plugin. Enabling automatic pre/post snapshots for DNF."
  mkdir -p /etc/dnf/plugins
  cat >/etc/dnf/plugins/snapper.conf <<'EOF'
[main]
enabled = true
# If plugin supports descriptions, keep it minimal
pre_tx_description = "pre dnf transaction"
post_tx_description = "post dnf transaction"
EOF
  AUTOSNAP_OK=true
else
  warn "DNF snapper plugin not detected."
fi

# Path 2: fallback using post-transaction actions (post-only)
# We'll generate post snapshots and rely on timeline/pre snapshots for broader coverage.
if ! $AUTOSNAP_OK; then
  if rpm -q python3-dnf-plugin-post-transaction-actions >/dev/null 2>&1; then
    log "Configuring fallback: DNF post-transaction actions to create a post snapshot automatically."
    mkdir -p /etc/dnf/plugins/post-transaction-actions.d
    cat >/etc/dnf/plugins/post-transaction-actions.d/90-snapper-autosnap.action <<'EOF'
# Create a post snapshot after successful DNF transaction
# Syntax: regex_for_package  command_to_run
.*  /usr/bin/snapper -c root create --description "dnf post-transaction $(date +%Y-%m-%d_%H:%M:%S)" --cleanup-algorithm "number"
EOF
    AUTOSNAP_OK=true
  else
    warn "Post-transaction actions plugin not installed. Using wrapper fallback for DNF."
  fi
fi

# Path 3: last-resort wrapper for dnf that creates a pre snapshot for upgrade/install/remove
# Installs /usr/local/sbin/dnf (earlier in PATH) to wrap upgrade-like operations.
if ! $AUTOSNAP_OK; then
  log "Installing a safe wrapper for DNF to take pre-snapshots on upgrade/install/remove."
  mkdir -p /usr/local/sbin
  if [ -x /usr/local/sbin/dnf ]; then
    cp -a /usr/local/sbin/dnf "/usr/local/sbin/dnf.bak.${DATESTAMP}"
  fi
  cat >/usr/local/sbin/dnf <<'EOF'
#!/usr/bin/env bash
# Wrapper that creates a pre snapshot for upgrade/install/remove/distro-sync
set -euo pipefail

REAL_DNF="/usr/bin/dnf"
NEED_PRESNAP=false

for arg in "$@"; do
  case "$arg" in
    upgrade*|update*|install|remove|autoremove|distro-sync)
      NEED_PRESNAP=true
      ;;
  esac
done

if $NEED_PRESNAP; then
  DESC="pre dnf: $*"
  /usr/bin/snapper -c root create --type pre --description "$DESC" --cleanup-algorithm "number" || true
fi

exec "$REAL_DNF" "$@"
EOF
  chmod +x /usr/local/sbin/dnf
  log "Wrapper installed at /usr/local/sbin/dnf."
fi

# ---------- Enable grub-btrfs daemon ----------
log "Enabling grub-btrfs daemon (auto-updates GRUB menu on new snapshots)..."
systemctl enable --now grub-btrfsd.service || {
  warn "Could not enable grub-btrfsd.service automatically."
}

# Verify that grub-btrfs.cfg will be in GRUB_DIR
mkdir -p "$GRUB_DIR"
if [ ! -f "$GRUB_DIR/grub-btrfs.cfg" ]; then
  log "Creating initial grub-btrfs.cfg placeholder..."
  echo '# generated by grub-btrfsd' > "$GRUB_DIR/grub-btrfs.cfg"
fi

# ---------- Create an initial baseline snapshot pair ----------
log "Creating initial pre/post baseline snapshots (for GRUB menu population)..."
snapper -c root create --type pre  --description "baseline pre ${DATESTAMP}"  --cleanup-algorithm "number" || true
snapper -c root create --type post --description "baseline post ${DATESTAMP}" --cleanup-algorithm "number" || true

# Give grub-btrfsd a moment to regenerate its config
sleep 2

# ---------- Regenerate GRUB config once ----------
log "Regenerating GRUB configuration (once) to ensure snapshot include scripts are present..."
if $is_uefi; then
  grub2-mkconfig -o /boot/efi/EFI/fedora/grub.cfg || warn "grub2-mkconfig (UEFI) failed. Verify GRUB setup manually."
else
  grub2-mkconfig -o /boot/grub2/grub.cfg || warn "grub2-mkconfig (BIOS) failed. Verify GRUB setup manually."
fi

log "All done ✅"
echo
echo "Next steps / verification:"
echo "  1) Check grub-btrfs daemon:    systemctl status grub-btrfsd"
echo "  2) List snapshots:              snapper -c root list"
echo "  3) Confirm GRUB entries file:   ls -l $GRUB_DIR/grub-btrfs.cfg"
echo "  4) Trigger a snapshot by doing: sudo dnf upgrade   (then reboot to see GRUB snapshot entries)"
echo
echo "If you used the DNF wrapper fallback, any 'dnf upgrade/install/remove' will create a pre snapshot automatically."