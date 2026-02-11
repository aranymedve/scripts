#!/bin/bash
set -euo pipefail
trap 'echo "Error on line $LINENO: $BASH_COMMAND" >&2' ERR

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

sudo hostnamectl set-hostname "beartp"

# Add Visual Studio Code repository
sudo sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo'

# Add RPMFusion repositories
sudo dnf install https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm -y

# Update system
sudo dnf upgrade --refresh -y
sudo dnf check

# Install core packages with vulkan support
sudo dnf swap -y ffmpeg-free ffmpeg --allowerasing
sudo dnf install -y mc remmina git fuse fuse-libs \
  make wget build-essential gpg vlc btop htop ncdu \
  NetworkManager-openvpn NetworkManager-l2tp-gnome \
  ca-certificates curl flatpak flameshot code \
  steam gamemode mesa-vulkan-drivers vulkan-tools \
  kernel-headers kernel-devel dkms bridge-utils \
  mesa-dri-drivers vulkan-loader mesa-libGLU lutris mangohud \
  mesa-va-drivers-freeworld mesa-vdpau-drivers-freeworld \
  libvirt virt-install qemu-kvm gstreamer1-plugin-openh264 mozilla-openh264 \
  gstreamer1-plugins-{bad-\*,good-\*,base} \
  gstreamer1-plugin-openh264 gstreamer1-libav lame\* --exclude=gstreamer1-plugins-bad-free-devel
  
# Install development tools group
sudo dnf group install -y development-tools multimedia sound-and-video

sudo dnf autoremove -y

# Git configuration
git config --global user.name "Zsolt Aranyi"
git config --global user.email aranymedve@gmail.com

# Copy remmina files
mkdir -p "$HOME/.local/share/remmina"
cp -a "$SCRIPT_DIR/remmina/." "$HOME/.local/share/remmina/" || true

# Download UpNote AppImage
mkdir -p "$HOME/Letöltések"
wget -O "$HOME/Letöltések/UpNote.AppImage" https://download.getupnote.com/app/UpNote.AppImage

# Install Docker Desktop
sudo dnf install -y dnf-plugins-core deja-dup
sudo dnf config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo
sudo dnf install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
wget -O "$HOME/Letöltések/docker-desktop-x86_64.rpm" https://desktop.docker.com/linux/main/x86_64/docker-desktop-x86_64.rpm
sudo dnf install -y "$HOME/Letöltések/docker-desktop-x86_64.rpm"
systemctl --user start docker-desktop || true

#install Vivaldi browser
sudo dnf config-manager --add-repo https://repo.vivaldi.com/archive/vivaldi-fedora.repo
sudo dnf install -y vivaldi-stable dnsconfd

# Import Dimenzio VPN
sudo nmcli connection import type openvpn file "$SCRIPT_DIR/Dimenzio.ovpn"

# Copy gamemode config
cp "$SCRIPT_DIR/gamemode.ini" "$HOME/.config/gamemode/gamemode.ini"

# Flatpak setup
# Remove the limited Fedora repo
flatpak remote-delete fedora || true
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo || true
flatpak install -y com.viber.Viber com.synology.SynologyDrive com.synology.SynologyAssistant \
  com.heroicgameslauncher.hgl com.anydesk.Anydesk com.emqx.MQTTX com.adobe.Reader \
  com.spotify.Client org.telegram.desktop com.github.IsmaelMartinez.teams_for_linux \
  com.freerdp.FreeRDP it.mijorus.gearlever com.github.iwalton3.jellyfin-media-player || true

# Firmware updates
sudo fwupdmgr refresh --force
sudo fwupdmgr get-updates
sudo fwupdmgr update

sudo -v && wget -nv -O- https://download.calibre-ebook.com/linux-installer.sh | sudo sh /dev/stdin

#flatpak auto update service
# Create the service unit
sudo tee /etc/systemd/system/flatpak-update.service > /dev/null <<'EOF'
[Unit]
Description=Update Flatpak apps automatically

[Service]
Type=oneshot
ExecStart=/usr/bin/flatpak update -y --noninteractive
EOF

# Create the timer unit
sudo tee /etc/systemd/system/flatpak-update.timer > /dev/null <<'EOF'
[Unit]
Description=Run Flatpak update every 24 hours
Wants=network-online.target
Requires=network-online.target
After=network-online.target

[Timer]
OnBootSec=120
OnUnitActiveSec=24h

[Install]
WantedBy=timers.target
EOF

# Reload systemd and enable the timer
sudo systemctl daemon-reload
sudo systemctl enable --now flatpak-update.timer

# Check the status to verify everything is working
sudo systemctl status flatpak-update.timer

sudo systemctl disable NetworkManager-wait-online.service

# Add TLP Repository 
sudo dnf install -y \
  https://repo.linrunner.de/fedora/tlp/repos/releases/tlp-release.fc$(rpm -E %fedora).noarch.rpm

# Remove conflicting power profiles daemon
sudo dnf remove -y tuned tuned-ppd

# Install TLP
sudo dnf install -y tlp tlp-rdw

# Enable TLP service 
sudo systemctl enable tlp.service

# Mask the following services to avoid conflicts
sudo systemctl mask systemd-rfkill.service systemd-rfkill.socket

#Encrypted DNS

sudo systemctl enable --now dnsconfd

sudo mkdir -p /etc/NetworkManager/conf.d
sudo tee /etc/NetworkManager/conf.d/global-dot.conf > /dev/null <<EOF
[main]
dns=dnsconfd

[global-dns]
resolve-mode=exclusive

[global-dns-domain-*]
servers=dns+tls://1.1.1.1#one.one.one.one
EOF

sudo systemctl restart NetworkManager

#system snapshot setup
sudo dnf install -y btrfs-assistant btrbk snapper
sudo systemctl enable --now snapper-timeline.timer
sudo systemctl enable --now snapper-cleanup.timer
