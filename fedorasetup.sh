#!/bin/bash
sudo hostnamectl set-hostname "beartp"

sudo sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo'

sudo dnf upgrade --refresh
sudo dnf check
sudo dnf install https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm -y

sudo dnf install git curl wget calibre dnf-utils vlc rpmfusion-free-release-tainted rpmfusion-nonfree-release-tainted steam remmina mc @development-tools kernel-headers kernel-devel dkms bridge-utils libvirt virt-install qemu-kvm gstreamer1-plugin-openh264 mozilla-openh264 NetworkManager-openvpn NetworkManager-l2tp-gnome code -y

sudo dnf group install -y development-tools vlc

sudo dnf group upgrade --with-optional Multimedia core --setop="install_weak_deps=False" --exclude=PackageKit-gstreamer-plugin sound-and-video -y
sudo dnf autoremove

#flatpak stuff
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
flatpak install -y com.viber.Viber
flatpak install -y com.synology.SynologyDrive
flatpak install -y com.synology.SynologyAssistant
flatpak install -y com.heroicgameslauncher.hgl
flatpak install -y com.anydesk.Anydesk
flatpak install -y com.emqx.MQTTX
flatpak install -y com.adobe.Reader
flatpak install -y com.spotify.Client
flatpak install -y org.telegram.desktop
flatpak install -y com.github.IsmaelMartinez.teams_for_linux
flatpak install -y it.mijorus.gearlever
#flatpak install -y com.freerdp.FreeRDP

# vegyes tennivalók
wget -O /home/zsolt/Letöltések/UpNote.AppImage https://download.getupnote.com/app/UpNote.AppImage


sudo fwupdmgr refresh --force
sudo fwupdmgr get-updates
sudo fwupdmgr update


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

# settings restore from external backup

# export BACKUP=/run/media/$USER/NAME_OR_UUID_BACKUP_DRIVE/@home/$USER/
# sudo rsync -avuP $BACKUP/Desktop ~/
# sudo rsync -avuP $BACKUP/Documents ~/
# sudo rsync -avuP $BACKUP/Downloads ~/
# sudo rsync -avuP $BACKUP/Music ~/
# sudo rsync -avuP $BACKUP/Pictures ~/
# sudo rsync -avuP $BACKUP/Templates ~/
# sudo rsync -avuP $BACKUP/Videos ~/
# sudo rsync -avuP $BACKUP/.ssh ~/
# sudo rsync -avuP $BACKUP/.gnupg ~/

# sudo rsync -avuP $BACKUP/.local/share/applications ~/.local/share/
# sudo rsync -avuP $BACKUP/.gitconfig ~/
# sudo rsync -avuP $BACKUP/.gitkraken ~/
# sudo rsync -avuP $BACKUP/.config/Nextcloud ~/.config/

# sudo rsync -avuP $BACKUP/dynare ~/
# sudo rsync -avuP $BACKUP/.dynare ~/
# sudo rsync -avuP $BACKUP/Images ~/
# sudo rsync -avuP $BACKUP/SofortUpload ~/
# sudo rsync -avuP $BACKUP/Work ~/
# sudo rsync -avuP $BACKUP/Zotero ~/
# sudo rsync -avuP $BACKUP/MATLAB ~/
# sudo rsync -avuP $BACKUP/.matlab ~/

# sudo chown -R $USER:$USER /home/$USER # make sure I own everything
