#!/bin/bash
sudo hostnamectl set-hostname "beartp"


sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\nautorefresh=1\ntype=rpm-md\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" |sudo tee /etc/zypp/repos.d/vscode.repo > /dev/null

sudo zypper dup
sudo zypper --non-interactive install wget gpg git code mc remmina git make wget gpg vlc sudo NetworkManager-openvpn NetworkManager-l2tp ca-certificates curl flatpak flameshot libSDL2-2_0-0 steam steam-devices inotify-tools ca-certificates


git config --global user.name "Zsolt Aranyi"
git config --global user.email aranymedve@gmail.com

mkdir ~/.local/share/remmina
cp remmina/* ~/.local/share/remmina/

sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
sudo flatpak install -y --user com.viber.Viber
sudo flatpak install -y com.synology.SynologyDrive
sudo flatpak install -y com.synology.SynologyAssistant
sudo flatpak install -y com.heroicgameslauncher.hgl
sudo flatpak install -y com.anydesk.Anydesk
sudo flatpak install -y com.emqx.MQTTX
sudo flatpak install -y com.adobe.Reader
sudo flatpak install -y com.spotify.Client
sudo flatpak install -y org.telegram.desktop
sudo flatpak install -y com.github.IsmaelMartinez.teams_for_linux
sudo flatpak install -y com.freerdp.FreeRDP
sudo flatpak install -y it.mijorus.gearlever

sudo zypper addrepo https://brave-browser-rpm-release.s3.brave.com/brave-browser.repo

sudo zypper install brave-browser

wget -O /home/zsolt/Letöltések/UpNote.AppImage https://download.getupnote.com/app/UpNote.AppImage

sudo -v && wget -nv -O- https://download.calibre-ebook.com/linux-installer.sh | sudo sh /dev/stdin
