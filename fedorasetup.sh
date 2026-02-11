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
sudo dnf install -y mc remmina git \
  make wget build-essential gpg vlc btop htop ncdu \
  NetworkManager-openvpn NetworkManager-l2tp-gnome \
  ca-certificates curl flatpak flameshot code \
  steam gamemode mesa-vulkan-drivers vulkan-tools \
  kernel-headers kernel-devel dkms bridge-utils \
  libvirt virt-install qemu-kvm gstreamer1-plugin-openh264 mozilla-openh264

# Install development tools group
sudo dnf group install -y development-tools

# Install multimedia with optional codecs
sudo dnf group upgrade --with-optional Multimedia core --setop="install_weak_deps=False" --exclude=PackageKit-gstreamer-plugin sound-and-video -y

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
sudo dnf install -y dnf-plugins-core
sudo dnf config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo
sudo dnf install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
wget -O "$HOME/Letöltések/docker-desktop-x86_64.rpm" https://desktop.docker.com/linux/main/x86_64/docker-desktop-x86_64.rpm
sudo dnf install -y "$HOME/Letöltések/docker-desktop-x86_64.rpm"
systemctl --user start docker-desktop || true

# Import Dimenzio VPN
sudo nmcli connection import type openvpn file "$SCRIPT_DIR/Dimenzio.ovpn"

# Copy gamemode config
cp "$SCRIPT_DIR/gamemode.ini" "$HOME/.config/gamemode/gamemode.ini"

# Flatpak setup
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
flatpak install -y com.viber.Viber com.synology.SynologyDrive com.synology.SynologyAssistant \
  com.heroicgameslauncher.hgl com.anydesk.Anydesk com.emqx.MQTTX com.adobe.Reader \
  com.spotify.Client org.telegram.desktop com.github.IsmaelMartinez.teams_for_linux \
  com.freerdp.FreeRDP it.mijorus.gearlever com.github.iwalton3.jellyfin-media-player || true

# Firmware updates
sudo fwupdmgr refresh --force
sudo fwupdmgr get-updates
sudo fwupdmgr update

sudo -v && wget -nv -O- https://download.calibre-ebook.com/linux-installer.sh | sudo sh /dev/stdin