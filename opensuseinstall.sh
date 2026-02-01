#!/bin/bash
sudo hostnamectl set-hostname "beartp"


sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\nautorefresh=1\ntype=rpm-md\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" |sudo tee /etc/zypp/repos.d/vscode.repo > /dev/null





sudo zypper dup
sudo zypper --non-interactive install wget gpg git code mc remmina git make wget gpg vlc sudo NetworkManager-openvpn NetworkManager-l2tp ca-certificates curl flatpak flameshot libSDL2-2_0-0 steam steam-devices inotify-tools ca-certificates plasma-nm5-l2tp strongswan strongswan-ipsec

sudo zypper in --force NetworkManager-l2tp plasma-nm5-l2tp strongswan NetworkManager-strongswan

sudo systemctl enable --now strongswan

git config --global user.name "Zsolt Aranyi"
git config --global user.email aranymedve@gmail.com

mkdir ~/.local/share/remmina
cp remmina/* ~/.local/share/remmina/

flatpak remote-add --user --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

flatpak install -y com.viber.Viber com.synology.SynologyDrive com.synology.SynologyAssistant \
  com.heroicgameslauncher.hgl com.anydesk.Anydesk com.emqx.MQTTX com.adobe.Reader \
  com.spotify.Client org.telegram.desktop com.github.IsmaelMartinez.teams_for_linux \
  com.freerdp.FreeRDP it.mijorus.gearlever com.github.iwalton3.jellyfin-media-player || true


wget -O /home/zsolt/Letöltések/UpNote.AppImage https://download.getupnote.com/app/UpNote.AppImage

sudo -v && wget -nv -O- https://download.calibre-ebook.com/linux-installer.sh | sudo sh /dev/stdin

# Enable the repository
sudo tee /etc/zypp/repos.d/firefoxpwa.repo > /dev/null <<EOF
[firefoxpwa]
name=FirefoxPWA
type=rpm-md
baseurl=https://packagecloud.io/filips/FirefoxPWA/rpm_any/rpm_any/\$basearch
gpgkey=https://packagecloud.io/filips/FirefoxPWA/gpgkey
       https://packagecloud.io/filips/FirefoxPWA/gpgkey/filips-FirefoxPWA-912AD9BE47FEB404.pub.gpg
repo_gpgcheck=1
pkg_gpgcheck=1
autorefresh=1
enabled=1
EOF

# Import GPG key and update Zypper cache
sudo zypper --gpg-auto-import-keys refresh firefoxpwa

# Install the package
sudo zypper install firefoxpwa
