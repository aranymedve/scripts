#!/bin/bash
sudo ls
sudo echo 'fastestmirror=true' >> /etc/dnf/dnf.conf
sudo echo 'deltarpm=true' >> /etc/dnf/dnf.conf
sudo echo 'max_parallel_downloads=10' >> /etc/dnf/dnf.conf
sudo echo 'defaultyes=true' >> /etc/dnf/dnf.conf 

sudo hostnamectl set-hostname "beartp"

sudo update-crypto-policies --set DEFAULT:FEDORA32

sudo dnf update -y
sudo dnf upgrade -y
sudo dnf install calibre dnf-utils vlc chrome-gnome-shell -y
sudo dnf groupupdate sound-and-video
sudo dnf install -y libdvdcss
sudo dnf install gstreamer1-plugins-{bad-\*,good-\*,base} gstreamer1-plugin-openh264 gstreamer1-libav --exclude=gstreamer1-plugins-bad-free-devel lame\* --exclude=lame-devel -y
sudo dnf install https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm rpmfusion-free-release-tainted rpmfusion-nonfree-release-tainted -y
sudo dnf install \*-firmware gnome-tweaks gnome-extensions-app gnome-tweak-tool 'google-roboto*' 'mozilla-fira*' fira-code-fonts -y
sudo dnf install tlp tlp-rdw steam remmina mc @development-tools kernel-headers kernel-devel dkms bridge-utils libvirt virt-install qemu-kvm -y
sudo dnf config-manager --set-enabled fedora-cisco-openh264
sudo dnf install -y gstreamer1-plugin-openh264 mozilla-openh264
sudo dnf install -y NetworkManager-openconnect-gnome NetworkManager-openvpn-gnome NetworkManager-pptp-gnome NetworkManager-openconnect-gnome NetworkManager-l2tp-gnome

sudo dnf group upgrade --with-optional Multimedia core --setop="install_weak_deps=False" --exclude=PackageKit-gstreamer-plugin sound-and-video -y

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
#flatpak install -y com.heroicgameslauncher.hgl
flatpak install -y com.bitwarden.desktop
flatpak install -y com.anydesk.Anydesk
flatpak install -y com.github.d4nj1.tlpui
#flatpak install -y com.visualstudio.code 
flatpak install -y com.calibre_ebook.calibre
flatpak install -y com.emqx.MQTTX 
flatpak install -y com.adobe.Reader 
flatpak install -y flathub io.freetubeapp.FreeTube

sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc -y
sudo dnf config-manager --add-repo https://packages.microsoft.com/yumrepos/edge
sudo sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo'
sudo dnf check-update -y 
sudo dnf install code -y
sudo dnf install microsoft-edge-stable -y

#sudo dnf -y install qemu-kvm libvirt virt-install cirt-manager
#sudo dnf -y install edk2-ovmf swtpm swtpm-tools 
#sudo systemctl enable --now libvirtd
sudo gsettings set org.gnome.desktop.interface show-battery-percentage true

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
# 



