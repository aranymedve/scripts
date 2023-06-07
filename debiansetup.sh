#!/bin/bash
sudo ls

sudo hostnamectl set-hostname "beartp"

sudo apt update -y
sudo apt upgrade -y
sudo apt install calibre vlc lame\* fwupd \*-firmware gnome-tweaks  gnome-tweak-tool tlp tlp-rdw remmina mc dkms bridge-utils build-essential autoconf automake gdb libffi-dev zlib1g-dev libssl-dev git wget gpg -y

sudo fwupdmgr refresh --force
sudo fwupdmgr get-updates
sudo fwupdmgr update

flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
flatpak install -y flathub org.gnome.Extensions
flatpak install -y flathub com.mattjakeman.ExtensionManager
flatpak install -y com.viber.Viber
flatpak install -y com.synology.SynologyDrive
flatpak install -y com.synology.SynologyAssistant
flatpak install -y md.obsidian.Obsidian
flatpak install -y com.sindresorhus.Caprine
flatpak install -y com.heroicgameslauncher.hgl
#flatpak install -y com.bitwarden.desktop
flatpak install -y com.anydesk.Anydesk
flatpak install -y com.github.d4nj1.tlpui
#flatpak install -y com.visualstudio.code 
flatpak install -y com.calibre_ebook.calibre
flatpak install -y com.emqx.MQTTX 
flatpak install -y com.adobe.Reader 

wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
sudo install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
sudo sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'
rm -f packages.microsoft.gpg
sudo apt update
sudo apt install code

#uninstall
#sudo apt remove code
#sudo rm /etc/apt/sources.list.d/vscode.*
#sudo rm /etc/apt/trusted.gpg.d/ms_vscode_key.gpg