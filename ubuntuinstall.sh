#!/bin/bash
sudo hostnamectl set-hostname "beartp"

#sudo dpkg --add-architecture i386
sudo apt update
sudo apt-get install wget gpg git -y
git config --global user.email "zsolt.aranyi@gmail.com"
git config --global user.name "Zsolt Aranyi"


sudo snap remove firefox
sudo apt purge -y snapd
sudo apt update
sudo add-apt-repository -y ppa:mozillateam/ppa
echo '
Package: firefox*
Pin: release o=LP-PPA-mozillateam
Pin-Priority: 1001
' | sudo tee /etc/apt/preferences.d/mozilla-firefox
sudo apt update
sudo apt install -y firefox

sudo apt install -y software-properties-common apt-transport-https curl
curl -fsSL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg
sudo install -o root -g root -m 644 microsoft.gpg /usr/share/keyrings/
rm microsoft.gpg
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/microsoft.gpg] https://packages.microsoft.com/repos/code stable main" | sudo tee /etc/apt/sources.list.d/vscode.list
sudo apt update
sudo apt install -y code



sudo apt install -y mc remmina git \
  make wget build-essential gpg vlc apt-transport-https \
  sudo network-manager-openvpn network-manager-l2tp \
  ca-certificates curl flatpak flameshot

#sudo netselect-apt trixie
#sudo cp sources.list /etc/apt/sources.list
sudo apt update
sudo apt upgrade -y

sudo apt install software-properties-common apt-transport-https ca-certificates curl -y


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
#flatpak install -y com.calibre_ebook.calibre
flatpak install -y com.emqx.MQTTX
flatpak install -y com.adobe.Reader
#flatpak install -y io.freetubeapp.FreeTube
flatpak install -y com.spotify.Client

sudo apt install -y gnome-terminal
# Add Docker's official GPG key:
# Add Docker's official GPG key:
# Add Docker's official GPG key:
sudo apt-get update
sudo apt-get install ca-certificates curl -y
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y

wget -O /home/zsolt/Downloads/docker-desktop-amd64.deb https://desktop.docker.com/linux/main/amd64/docker-desktop-amd64.deb
sudo apt-get update
sudo apt-get install -y /home/zsolt/Downloads/docker-desktop-amd64.deb
systemctl --user start docker-desktop

cat << 'EOA' | tee /home/zsolt/gpginput.txt
%echo Generating a default key
Key-Type: RSA
Key-Length: 2048
Subkey-Type: RSA
Subkey-Length: 2048
Name-Real: Zsolt Aranyi
Name-Email: zsolt.aranyi@gmail.com
Expire-Date: 0
Passphrase: Medve63383!
%commit
%echo done
EOA
gpg --batch --generate-key /home/zsolt/gpginput.txt
pass init $(gpg --list-secret-keys --keyid-format=long --with-colons | awk -F: '/^sec/ {print $5}')

sudo -v && wget -nv -O- https://download.calibre-ebook.com/linux-installer.sh | sudo sh /dev/stdin

