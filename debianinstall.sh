#!/bin/bash
sudo hostnamectl set-hostname "beartp"
sudo cp /etc/apt/sources.list /etc/apt/sources.list.bak
sudo sed -i 's/main/main contrib non-free non-free-firmware/g' /etc/apt/sources.list
sudo dpkg --add-architecture i386


sudo apt update
sudo apt-get install wget gpg
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
sudo apt update
sudo apt install -y netselect-apt mc remmina git \
  make wget build-essential gpg vlc apt-transport-https \
  sudo network-manager-openvpn network-manager-l2tp \
  ca-certificates curl flatpak flameshot code libsdl2-image-2.0-0 \
  steam-installer steam-devices


git config --global user.name "Zsolt Aranyi"
git config --global user.email aranymedve@gmail.com

sudo netselect-apt trixie
sudo cp sources.list /etc/apt/sources.list
sudo apt update
sudo apt upgrade -y

sudo apt install apt-transport-https ca-certificates curl -y

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

sudo apt install -y gnome-terminal
# Add Docker's official GPG key:
sudo apt update
sudo apt install -y ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
wget -O /home/zsolt/Letöltések/docker-desktop-amd64.deb https://desktop.docker.com/linux/main/amd64/docker-desktop-amd64.deb
sudo apt-get update
sudo apt-get install -y /home/zsolt/Letöltések/docker-desktop-amd64.deb
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

