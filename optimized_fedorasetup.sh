#!/bin/bash
set -euo pipefail
trap 'echo "Error on line $LINENO: $BASH_COMMAND" >&2' ERR

# Set hostname
sudo hostnamectl set-hostname "beartp"

# Backup sources list and modify it
sudo cp /etc/yum.repos.d/vscode.repo /etc/yum.repos.d/vscode.repo.bak

# Add Visual Studio Code repository
sudo sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo'

# Update and install necessary packages
sudo dnf upgrade --refresh
sudo dnf check
sudo dnf install -y https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

# Install essential packages
sudo dnf install -y git curl wget calibre dnf-utils vlc rpmfusion-free-release-tainted rpmfusion-nonfree-release-tainted steam remmina mc @development-tools kernel-headers kernel-devel dkms bridge-utils libvirt virt-install qemu-kvm gstreamer1-plugin-openh264 mozilla-openh264 NetworkManager-openvpn NetworkManager-l2tp-gnome code

# Install development tools
sudo dnf group install -y development-tools vlc

# Upgrade multimedia group
sudo dnf group upgrade --with-optional Multimedia core --setop="install_weak_deps=False" --exclude=PackageKit-gstreamer-plugin sound-and-video

# Clean up
sudo dnf autoremove

# Flatpak setup
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
flatpak install -y com.viber.Viber
flatpak install -y com.synology.SynologyDrive
