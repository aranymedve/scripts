#!/bin/bash
sudo ls
echo 'fastestmirror=true' | sudo tee -a /etc/dnf/dnf.conf
echo 'deltarpm=true' | sudo tee -a /etc/dnf/dnf.conf
echo 'max_parallel_downloads=10' | sudo tee -a /etc/dnf/dnf.conf
echo 'defaultyes=true' | sudo tee -a /etc/dnf/dnf.conf 

sudo hostnamectl set-hostname "beartp"

sudo update-crypto-policies --set DEFAULT:FEDORA32

sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc -y
sudo dnf config-manager --add-repo https://packages.microsoft.com/yumrepos/edge
sudo dnf config-manager --set-enabled fedora-cisco-openh264

sudo sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo'

sudo dnf upgrade --refresh
sudo dnf check
sudo dnf install https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm -y
sudo dnf install timeshift gnome-shell-extension-pop-shell git curl wget calibre dnf-utils vlc chrome-gnome-shell libdvdcss gstreamer1-plugins-{bad-\*,good-\*,base} gstreamer1-plugin-openh264 gstreamer1-libav --exclude=gstreamer1-plugins-bad-free-devel lame\* --exclude=lame-devel rpmfusion-free-release-tainted rpmfusion-nonfree-release-tainted \*-firmware gnome-tweaks gnome-extensions-app gnome-tweak-tool 'google-roboto*' 'mozilla-fira*' fira-code-fonts tlp tlp-rdw steam remmina mc @development-tools kernel-headers kernel-devel dkms bridge-utils libvirt virt-install qemu-kvm gstreamer1-plugin-openh264 mozilla-openh264 NetworkManager-openconnect-gnome NetworkManager-openvpn-gnome NetworkManager-pptp-gnome NetworkManager-openconnect-gnome NetworkManager-l2tp-gnome dconf-editor redshift fastfetch code microsoft-edge-stable-y
sudo dnf install -y gnome-shell-extension-just-perfection gnome-shell-extension-burn-my-windows gnome-shell-extension-blur-my-shell

dnf groupinstall -y "Development Tools"

# sudo dnf groupupdate sound-and-video 

sudo dnf group upgrade --with-optional Multimedia core --setop="install_weak_deps=False" --exclude=PackageKit-gstreamer-plugin sound-and-video -y
sudo dnf autoremove

#flatpak stuff

flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
flatpak install -y flathub org.gnome.Extensions
flatpak install -y flathub com.mattjakeman.ExtensionManager
flatpak install -y com.viber.Viber
flatpak install -y com.synology.SynologyDrive
flatpak install -y com.synology.SynologyAssistant
flatpak install -y md.obsidian.Obsidian
flatpak install -y com.sindresorhus.Caprine
flatpak install -y com.heroicgameslauncher.hgl
flatpak install -y com.bitwarden.desktop
flatpak install -y com.anydesk.Anydesk
flatpak install -y com.github.d4nj1.tlpui
flatpak install -y com.calibre_ebook.calibre
flatpak install -y com.emqx.MQTTX 
flatpak install -y com.adobe.Reader 
flatpak install -y flathub io.freetubeapp.FreeTube
flatpak install -y flathub com.spotify.Client

# vegyes tennivalók

sudo gsettings set org.gnome.desktop.interface show-battery-percentage true
sudo systemctl disable NetworkManager-wait-online.service
sudo rm /etc/xdg/autostart/org.gnome.Software.desktop
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