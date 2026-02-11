#!/usr/bin bash
set -euo pipefail

# Migrate existing Fedora (Btrfs) to Timeshift-compatible layout:
#   @       -> /
#   @home   -> /home
#   @log    -> /var/log
#   @cache  -> /var/cache
#   @tmp    -> /var/tmp
#
# Safe-guards:
#  - Must be run from Live/Rescue (not from mounted root)
#  - Creates read-only backup snapshot of old root
#  - Aborts if @ already exists
#  - Preserves ACLs, xattrs, SELinux contexts (rsync -aHAX) + triggers relabel

# -------- Config / constants ----------
DEVICE="${1:-}"
TOP="/mnt/btrfs_top"      # mounted with subvolid=5 (top level)
TARGET="/mnt/btrfs_root"  # mounted with subvol=@
DATESTAMP="$(date +%Y%m%d-%H%M%S)"
BACKUP_NAME="_backup_root_PREMIG_${DATESTAMP}"

# -------- Utility helpers -------------
info() { echo -e "\e[1;32m[INFO]\e[0m $*"; }
warn() { echo -e "\e[1;33m[WARN]\e[0m $*"; }
err()  { echo -e "\e[1;31m[ERROR]\e[0m $*" >&2; }
die()  { err "$*"; exit 1; }
need() { command -v "$1" >/dev/null 2>&1 || die "Missing required command: $1"; }

cleanup() {
  set +e
  # Try to unmount in reverse order
  mountpoint -q "$TARGET/var/tmp" && umount "$TARGET/var/tmp"
  mountpoint -q "$TARGET/var/cache" && umount "$TARGET/var/cache"
  mountpoint -q "$TARGET/var/log" && umount "$TARGET/var/log"
  mountpoint -q "$TARGET/home" && umount "$TARGET/home"
  mountpoint -q "$TARGET/boot/efi" && umount "$TARGET/boot/efi"
  mountpoint -q "$TARGET/boot" && umount "$TARGET/boot"
  mountpoint -q "$TARGET" && umount "$TARGET"
  mountpoint -q "$TOP" && umount "$TOP"
  rmdir "$TARGET" "$TOP" 2>/dev/null || true
}
trap cleanup EXIT

# -------- Pre-flight checks -----------
[ -n "$DEVICE" ] || die "Usage: $0 /dev/<btrfs-root-partition>"

need lsblk
need blkid
need btrfs
need rsync
need awk
need sed
need grep

# must be root
[ "$(id -u)" -eq 0 ] || die "Run as root."

# Ensure we're not on the installed system (simple guard: /run/archiso or live hostname check omitted).
if findmnt -no SOURCE / 2>/dev/null | grep -q "^$DEVICE"; then
  die "Refusing to run against the currently mounted root. Boot a Fedora Live/Rescue environment."
fi

[ -b "$DEVICE" ] || die "Block device not found: $DEVICE"
FSTYPE=$(blkid -s TYPE -o value "$DEVICE" || true)
[ "$FSTYPE" = "btrfs" ] || die "Device is not Btrfs: $DEVICE (type=$FSTYPE)"

# Mount top-level to inspect subvolumes
info "Mounting top-level (subvolid=5) of $DEVICE at $TOP ..."
mkdir -p "$TOP"
mount -o subvolid=5 "$DEVICE" "$TOP"

# Detect default subvolume (should be Fedora 'root')
DEF_ID_LINE=$(btrfs subvolume get-default "$TOP")
DEF_ID=$(echo "$DEF_ID_LINE" | awk '{print $NF}')
[ -n "$DEF_ID" ] || die "Failed to get default subvolume ID."

# Map ID -> path
DEF_PATH=$(btrfs subvolume list -o "$TOP" | awk -v id="$DEF_ID" '$2==id {print $NF}')
[ -n "$DEF_PATH" ] || die "Failed to map default subvolume ID=$DEF_ID to a path."

info "Current default subvolume: ID=$DEF_ID path='$DEF_PATH'"

# Guard against OSTree/Silverblue (not supported here)
if [ -e "$TOP/$DEF_PATH/ostree" ] || grep -qi 'OSTREE' "$TOP/$DEF_PATH/etc/os-release" 2>/dev/null; then
  die "Detected OSTree-based system (Silverblue/Kinoite/variant). This script does not support it."
fi

# Refuse if @ already exists (avoid clobber)
if [ -e "$TOP/@/.snapshots" ] || [ -e "$TOP/@home" ] || [ -e "$TOP/@log" ] || [ -e "$TOP/@cache" ] || [ -e "$TOP/@tmp" ]; then
  die "One or more Timeshift-style subvolumes already exist under top-level. Aborting to avoid conflicts."
fi

# Create a read-only backup snapshot of the current root
info "Creating read-only backup snapshot of '$DEF_PATH' as '$BACKUP_NAME' ..."
btrfs subvolume snapshot -r "$TOP/$DEF_PATH" "$TOP/$BACKUP_NAME"

# Create '@' as a writable snapshot of the existing root
info "Creating writable snapshot '@' from '$DEF_PATH' ..."
btrfs subvolume snapshot "$TOP/$DEF_PATH" "$TOP/@"

# Create additional subvolumes
for sv in @home @log @cache @tmp; do
  info "Creating subvolume $sv ..."
  btrfs subvolume create "$TOP/$sv"
done

# Mount new root (@) to migrate directories
info "Mounting new root subvolume '@' at $TARGET ..."
mkdir -p "$TARGET"
mount -o subvol=@ "$DEVICE" "$TARGET"

# We will copy from the content inside the newly mounted '@'
# and place data into sibling subvolumes mounted via top-level path.
# To avoid overlaying, copy from $TARGET/* to $TOP/@home etc.

RSYNC_OPTS=(-aHAX --numeric-ids --inplace --info=progress2)

# Migrate /home
if [ -d "$TARGET/home" ] && [ -n "$(ls -A "$TARGET/home" 2>/dev/null || true)" ]; then
  info "Migrating /home -> @home ..."
  rsync "${RSYNC_OPTS[@]}" "$TARGET/home/" "$TOP/@home/"
  rm -rf "$TARGET/home/"*
fi

# Migrate /var/log
if [ -d "$TARGET/var/log" ] && [ -n "$(ls -A "$TARGET/var/log" 2>/dev/null || true)" ]; then
  info "Migrating /var/log -> @log ..."
  rsync "${RSYNC_OPTS[@]}" "$TARGET/var/log/" "$TOP/@log/"
  rm -rf "$TARGET/var/log/"*
fi

# Migrate /var/cache
if [ -d "$TARGET/var/cache" ] && [ -n "$(ls -A "$TARGET/var/cache" 2>/dev/null || true)" ]; then
  info "Migrating /var/cache -> @cache ..."
