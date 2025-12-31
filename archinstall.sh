#!/bin/bash
set -euo pipefail
trap 'echo "Error on line $LINENO: $BASH_COMMAND" >&2' ERR

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

sudo hostnamectl set-hostname "beartp"

# Enable multilib repository (required for some 32-bit libraries)
if ! grep -q '^\[multilib\]' /etc/pacman.conf; then
  sudo cp /etc/pacman.conf /etc/pacman.conf.bak
  sudo sed -i '/#\[multilib\]/,/^#Include/ s/^#//' /etc/pacman.conf || true
  sudo pacman -Syy --noconfirm
fi

# Update system and install base packages
sudo pacman -Syu --noconfirm
sudo pacman -S --noconfirm --needed wget gnupg git base-devel vim networkmanager

# Enable NetworkManager
sudo systemctl enable --now NetworkManager

# Install yay (AUR helper) if not present
if ! command -v yay >/dev/null 2>&1; then
  TMPDIR=$(mktemp -d)
  git clone https://aur.archlinux.org/yay.git "$TMPDIR/yay"
  pushd "$TMPDIR/yay" >/dev/null
  makepkg -si --noconfirm
  popd >/dev/null
  rm -rf "$TMPDIR"
fi

# Install packages from official repos
sudo pacman -S --noconfirm --needed mc remmina make vlc btop htop ncdu \
  networkmanager-openvpn networkmanager-l2tp openvpn ca-certificates curl \
  flatpak flameshot gnome-terminal mesa vulkan-tools steam lutris

# Flatpak apps
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
flatpak install -y com.viber.Viber com.synology.SynologyDrive com.synology.SynologyAssistant \
  com.heroicgameslauncher.hgl com.anydesk.Anydesk com.emqx.MQTTX com.adobe.Reader \
  com.spotify.Client org.telegram.desktop com.github.IsmaelMartinez.teams_for_linux \
  com.freerdp.FreeRDP it.mijorus.gearlever || true

# Docker
sudo pacman -S --noconfirm --needed docker docker-compose
sudo systemctl enable --now docker

# Configure git
git config --global user.name "Zsolt Aranyi"
git config --global user.email "aranymedve@gmail.com"

# Restore remmina configs if provided
mkdir -p "$HOME/.local/share/remmina"
cp -a "$SCRIPT_DIR/remmina/." "$HOME/.local/share/remmina/" || true

# Copy gamemode config if present
if [ -f "$SCRIPT_DIR/gamemode.ini" ]; then
  mkdir -p "$HOME/.config/gamemode"
  cp "$SCRIPT_DIR/gamemode.ini" "$HOME/.config/gamemode/gamemode.ini"
fi

# Import VPN (.ovpn) if NetworkManager supports it
if [ -f "$SCRIPT_DIR/Dimenzio.ovpn" ]; then
  sudo nmcli connection import type openvpn file "$SCRIPT_DIR/Dimenzio.ovpn" || true
fi

echo "Arch install script completed. Review output for errors."
