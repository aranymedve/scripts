#!/bin/bash
sudo hostnamectl set-hostname "beartp"


sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\nautorefresh=1\ntype=rpm-md\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" |sudo tee /etc/zypp/repos.d/vscode.repo > /dev/null

sudo zypper dup
sudo zypper --non-interactive install wget gpg git code \
  mc remmina git \
  make wget build-essential gpg vlc \
  sudo NetworkManager-openvpn NetworkManager-l2tp \
  ca-certificates curl flatpak flameshot libSDL2-2_0-0 \
  steam-installer steam-devices  \
  inotify-tools ca-certificates


git config --global user.name "Zsolt Aranyi"
git config --global user.email aranymedve@gmail.com

mkdir ~/.local/share/remmina
cp remmina/* ~/.local/share/remmina/

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
flatpak install -y com.freerdp.FreeRDP
flatpak install -y it.mijorus.gearlever

wget -O /home/zsolt/Letöltések/UpNote.AppImage https://download.getupnote.com/app/UpNote.AppImage

sudo -v && wget -nv -O- https://download.calibre-ebook.com/linux-installer.sh | sudo sh /dev/stdin
