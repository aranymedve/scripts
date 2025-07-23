#!/bin/bash
sudo hostnamectl set-hostname "beartp"

sudo apt update
sudo apt install wget
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg
sudo install -D -o root -g root -m 644 microsoft.gpg /usr/share/keyrings/microsoft.gpg
rm -f microsoft.gpg

cat << 'EOF' | sudo tee /etc/apt/sources.list.d/vscode.sources
Types: deb
URIs: https://packages.microsoft.com/repos/code
Suites: stable
Components: main
Architectures: amd64,arm64,armhf
Signed-By: /usr/share/keyrings/microsoft.gpg
EOF

sudo apt install -y netselect-apt mc remmina git make wget build-essential gpg vlc code flatpak software-properties-common apt-transport-https ca-certificates curl flatpak code

sudo netselect-apt trixie
sudo cp sources.list /etc/apt/sources.list
sudo apt update
sudo apt upgrade -y

curl -fSsL https://dl.google.com/linux/linux_signing_key.pub | sudo gpg --dearmor | sudo tee /usr/share/keyrings/google-chrome.gpg >> /dev/null
echo deb [arch=amd64 signed-by=/usr/share/keyrings/google-chrome.gpg] http://dl.google.com/linux/chrome/deb/ stable main | sudo tee /etc/apt/sources.list.d/google-chrome.list
sudo apt update
sudo apt install google-chrome-stable

flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
#flatpak install -y org.gnome.Extensions
#flatpak install -y com.mattjakeman.ExtensionManager
flatpak install -y com.viber.Viber
flatpak install -y com.synology.SynologyDrive
flatpak install -y com.synology.SynologyAssistant
#flatpak install -y md.obsidian.Obsidian
flatpak install -y com.sindresorhus.Caprine
flatpak install -y com.heroicgameslauncher.hgl
flatpak install -y com.bitwarden.desktop
flatpak install -y com.anydesk.Anydesk
#flatpak install -y com.github.d4nj1.tlpui
#flatpak install -y com.visualstudio.code
flatpak install -y com.calibre_ebook.calibre
flatpak install -y com.emqx.MQTTX
flatpak install -y com.adobe.Reader
#flatpak install -y io.freetubeapp.FreeTube
flatpak install -y com.spotify.Client
