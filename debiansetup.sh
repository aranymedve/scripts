#!/bin/bash


sudo hostnamectl set-hostname "beartp"
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
sudo install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
sudo sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'
rm -f packages.microsoft.gpg
sudo apt install software-properties-common apt-transport-https ca-certificates curl -y
curl -fSsL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor | sudo tee /usr/share/keyrings/microsoft-edge.gpg > /dev/null
echo 'deb [signed-by=/usr/share/keyrings/microsoft-edge.gpg] https://packages.microsoft.com/repos/edge stable main' | sudo tee /etc/apt/sources.list.d/microsoft-edge.list

sudo apt update -y
sudo apt upgrade -y
sudo apt install lame\* fwupd \*-firmware gnome-tweaks remmina mc dkms bridge-utils build-essential autoconf automake gdb libffi-dev zlib1g-dev libssl-dev git wget gpg timeshift  git curl wget vlc chrome-gnome-shell \*-firmware gnome-extensions-app steam-devices remmina mc dkms bridge-utils  network-manager-openconnect-gnome network-manager-openvpn-gnome network-manager-pptp-gnome network-manager-openconnect-gnome network-manager-l2tp-gnome dconf-editor redshift code microsoft-edge-stable flatpak -y

sudo fwupdmgr refresh --force
sudo fwupdmgr get-updates
sudo fwupdmgr update

flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
flatpak install -y org.gnome.Extensions
flatpak install -y com.mattjakeman.ExtensionManager
flatpak install -y com.viber.Viber
flatpak install -y com.synology.SynologyDrive
flatpak install -y com.synology.SynologyAssistant
flatpak install -y md.obsidian.Obsidian
flatpak install -y com.sindresorhus.Caprine
flatpak install -y com.heroicgameslauncher.hgl
flatpak install -y com.bitwarden.desktop
flatpak install -y com.anydesk.Anydesk
flatpak install -y com.github.d4nj1.tlpui
#flatpak install -y com.visualstudio.code 
flatpak install -y com.calibre_ebook.calibre
flatpak install -y com.emqx.MQTTX 
flatpak install -y com.adobe.Reader 
flatpak install -y io.freetubeapp.FreeTube
flatpak install -y com.spotify.Client

# Telepítendő extension-ök
# https://extensions.gnome.org/extension/5446/quick-settings-tweaker/
# https://extensions.gnome.org/extension/1401/bluetooth-quick-connect/
# https://extensions.gnome.org/extension/5425/battery-time/
# https://extensions.gnome.org/extension/615/appindicator-support/
# https://extensions.gnome.org/extension/1112/screenshot-tool/
# https://extensions.gnome.org/extension/779/clipboard-indicator/
# https://extensions.gnome.org/extension/6/applications-menu/
# https://extensions.gnome.org/extension/5263/gtk4-desktop-icons-ng-ding/
# https://extensions.gnome.org/extension/6655/openweather/
# https://extensions.gnome.org/extension/3088/extension-list/
# https://extensions.gnome.org/extension/5489/search-light/
