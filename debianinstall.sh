#!/bin/bash
set -euo pipefail
trap 'echo "Error on line $LINENO: $BASH_COMMAND" >&2' ERR
 
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOWNLOADS_DIR="$HOME/Letöltések"
REMMINA_DIR="$HOME/.local/share/remmina"
GAMEMODE_DIR="$HOME/.config/gamemode"
CONFIG_DIR="$HOME/.config"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# ============================================================================
# TUI MENU SYSTEM
# ============================================================================

show_menu() {
    clear
    echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║       Debian 13 Setup & Optimization Script                ║${NC}"
    echo -e "${BLUE}╠════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${BLUE}║ 1.  System Setup (hostname, repos, updates)                ║${NC}"
    echo -e "${BLUE}║ 2.  Install Core Packages & Development Tools             ║${NC}"
    echo -e "${BLUE}║ 3.  Install & Configure Docker                            ║${NC}"
    echo -e "${BLUE}║ 4.  Install Browsers (Vivaldi, Code)                       ║${NC}"
    echo -e "${BLUE}║ 5.  Setup VPN Connections                                 ║${NC}"
    echo -e "${BLUE}║ 6.  Setup Flatpak & Applications                          ║${NC}"
    echo -e "${BLUE}║ 7.  Install Power Management (TLP)                         ║${NC}"
    echo -e "${BLUE}║ 8.  Setup Encrypted DNS (Systemd-resolved)                 ║${NC}"
    echo -e "${BLUE}║ 9.  Setup System Snapshots (Snapper)                       ║${NC}"
    echo -e "${BLUE}║ 10. Setup Firmware Updates                                 ║${NC}"
    echo -e "${BLUE}║ 11. Install Multimedia & Codecs                            ║${NC}"
    echo -e "${BLUE}║ 12. Configure Git & Copy Config Files                      ║${NC}"
    echo -e "${BLUE}║ 13. Install Calibre eBook Manager                          ║${NC}"
    echo -e "${BLUE}║ 14. Generate GPG Keys & Password Manager                   ║${NC}"
    echo -e "${BLUE}║ 15. Run All Steps                                          ║${NC}"
    echo -e "${BLUE}║ 0.  Exit                                                   ║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
    echo -e "${YELLOW}Select an option [0-15]:${NC} "
}

# ============================================================================
# UTILITY FUNCTIONS
# ============================================================================

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

press_enter() {
    echo -e "${YELLOW}Press Enter to continue...${NC}"
    read -r
}

# ============================================================================
# SETUP FUNCTIONS
# ============================================================================

setup_system() {
    log_info "Setting up system..."
    
    sudo hostnamectl set-hostname "beartp"
    
    log_info "Backing up and updating sources.list..."
    sudo cp /etc/apt/sources.list /etc/apt/sources.list.bak
    sudo sed -i 's/main$/main contrib non-free non-free-firmware/g' /etc/apt/sources.list
    sudo dpkg --add-architecture i386
    
    log_info "Setting up Microsoft GPG key for VS Code..."
    sudo apt update
    sudo apt install -y wget gnupg curl
    TMP_MPG=$(mktemp)
    wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > "$TMP_MPG"
    sudo install -D -o root -g root -m 644 "$TMP_MPG" /usr/share/keyrings/microsoft.gpg
    rm -f "$TMP_MPG"
    
    log_info "Adding VS Code repository..."
    cat << 'EOF' | sudo tee /etc/apt/sources.list.d/vscode.sources
Types: deb
URIs: https://packages.microsoft.com/repos/code
Suites: stable
Components: main
Architectures: amd64,arm64,armhf
Signed-By: /usr/share/keyrings/microsoft.gpg
EOF
    
    log_info "Updating system..."
    sudo apt update
    sudo apt upgrade -y
    
    log_warn "Debsums check (optional, may take time)..."
    sudo apt install -y debsums
    sudo debsums -c || true
    
    log_info "System setup complete!"
    press_enter
}

install_core_packages() {
    log_info "Installing core packages and development tools..."
    
    sudo apt install -y \
        mc remmina git fuse libfuse2 \
        make wget build-essential gpg vlc btop htop ncdu \
        network-manager-openvpn network-manager-l2tp \
        ca-certificates curl flatpak flameshot code \
        steam-installer steam-devices \
        vulkan-tools vulkan-loader libvulkan1 libvulkan1:i386 \
        gamemode libgamemode0 \
        libsdl2-image-2.0-0 \
        libgl1-mesa-glx libgl1-mesa-glx:i386 \
        vainfo libva-glx2 libva-x11-2 gstreamer1.0-vaapi \
        bridge-utils \
        libvirt-daemon libvirt-clients qemu-system-x86 qemu-utils \
        gstreamer1.0-plugins-base gstreamer1.0-plugins-good \
        gstreamer1.0-plugins-bad gstreamer1.0-libav \
        gstreamer1.0-plugins-ugly lame sox libsox-fmt-all \
        timeshift snapper btrfs-assistant \
        inotify-tools deja-dup \
        lutris mangohud
    
    log_info "Installing development tools..."
    sudo apt install -y build-essential dkms linux-headers-$(uname -r) \
        python3-dev python3-pip git-lfs
    
    log_info "Installing fonts and localization..."
    sudo apt install -y fonts-dejavu fonts-liberation fonts-noto \
        language-pack-hu
    
    log_info "Cleanup..."
    sudo apt autoremove -y
    sudo apt autoclean -y
    
    log_info "Core packages installation complete!"
    press_enter
}

setup_docker() {
    log_info "Setting up Docker..."
    
    log_info "Adding Docker GPG key..."
    sudo apt update
    sudo install -m 0755 -d /etc/apt/keyrings
    sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
    sudo chmod a+r /etc/apt/keyrings/docker.asc
    
    log_info "Adding Docker repository..."
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
        sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    
    sudo apt update
    sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    
    log_info "Downloading Docker Desktop..."
    mkdir -p "$DOWNLOADS_DIR"
    wget -O "$DOWNLOADS_DIR/docker-desktop-amd64.deb" https://desktop.docker.com/linux/main/amd64/docker-desktop-amd64.deb
    sudo apt install -y "$DOWNLOADS_DIR/docker-desktop-amd64.deb"
    
    log_info "Starting Docker Desktop..."
    systemctl --user start docker-desktop || true
    
    log_info "Docker setup complete!"
    press_enter
}

install_browsers() {
    log_info "Installing browsers..."
    
    log_info "Adding Vivaldi repository..."
    wget -qO- https://repo.vivaldi.com/archive/linux_signing_key.pub | sudo apt-key add -
    echo "deb https://repo.vivaldi.com/archive/deb/ stable main" | \
        sudo tee /etc/apt/sources.list.d/vivaldi.list > /dev/null
    
    sudo apt update
    sudo apt install -y vivaldi-stable
    
    log_info "VS Code already included in system setup"
    
    log_info "Browsers installation complete!"
    press_enter
}

setup_vpn() {
    log_info "Setting up VPN connections..."
    
    if [ -f "$SCRIPT_DIR/Dimenzio.ovpn" ]; then
        log_info "Importing Dimenzio OpenVPN..."
        sudo nmcli connection import type openvpn file "$SCRIPT_DIR/Dimenzio.ovpn" || true
    else
        log_warn "Dimenzio.ovpn not found in $SCRIPT_DIR"
    fi
    
    log_info "Setting up 3CX+ L2TP VPN (if credentials available)..."
    sudo nmcli connection add type vpn con-name "3cx+" ifname -- vpn-type l2tp \
        vpn.data "gateway=3cxplusz.smstar.hu,ipsec-enabled=yes,ipsec-psk=l\`Nv=oO3CJgf'\`6tn.\"h,mru=1400,mtu=1400" \
        vpn.secrets "password=8\,t#BO.JL$W4.XYRdzBa,ipsec-secret=l\`Nv=oO3CJgf'\`6tn.\"h" \
        ipv4.never-default yes ipv6.never-default yes || true
    
    log_info "VPN setup complete!"
    press_enter
}

setup_flatpak() {
    log_info "Setting up Flatpak..."
    
    flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo || true
    
    log_info "Installing Flatpak applications..."
    flatpak install -y \
        com.viber.Viber \
        com.synology.SynologyDrive \
        com.synology.SynologyAssistant \
        com.heroicgameslauncher.hgl \
        com.anydesk.Anydesk \
        com.emqx.MQTTX \
        com.adobe.Reader \
        com.spotify.Client \
        org.telegram.desktop \
        com.github.IsmaelMartinez.teams_for_linux \
        com.freerdp.FreeRDP \
        it.mijorus.gearlever \
        com.github.iwalton3.jellyfin-media-player \
        || true
    
    log_info "Setting up Flatpak auto-update timer..."
    sudo tee /etc/systemd/system/flatpak-update.service > /dev/null <<'EOF'
[Unit]
Description=Update Flatpak apps automatically

[Service]
Type=oneshot
ExecStart=/usr/bin/flatpak update -y --noninteractive
EOF

    sudo tee /etc/systemd/system/flatpak-update.timer > /dev/null <<'EOF'
[Unit]
Description=Run Flatpak update every 24 hours
Wants=network-online.target
After=network-online.target

[Timer]
OnBootSec=120
OnUnitActiveSec=24h

[Install]
WantedBy=timers.target
EOF

    sudo systemctl daemon-reload
    sudo systemctl enable --now flatpak-update.timer
    
    log_info "Flatpak setup complete!"
    press_enter
}

setup_power_management() {
    log_info "Installing TLP for power management..."
    
    log_info "Adding TLP repository..."
    curl https://repo.linrunner.de/debian/focal/linrunner-keyring.gpg | \
        sudo tee /usr/share/keyrings/linrunner-keyring.gpg > /dev/null
    
    echo "deb [signed-by=/usr/share/keyrings/linrunner-keyring.gpg] https://repo.linrunner.de/debian/trixie trixie main" | \
        sudo tee /etc/apt/sources.list.d/tlp.list > /dev/null
    
    sudo apt update
    sudo apt install -y tlp tlp-rdw
    
    log_info "Removing conflicting power profiles..."
    sudo systemctl mask systemd-rfkill.service systemd-rfkill.socket || true
    
    log_info "Enabling TLP..."
    sudo systemctl enable tlp.service
    sudo systemctl start tlp.service || true
    
    log_info "Power management setup complete!"
    press_enter
}

setup_encrypted_dns() {
    log_info "Setting up encrypted DNS with systemd-resolved..."
    
    log_info "Configuring systemd-resolved for DNS over TLS..."
    sudo tee /etc/systemd/resolved.conf > /dev/null <<'EOF'
[Resolve]
DNS=1.1.1.1 1.0.0.1
FallbackDNS=8.8.8.8 8.8.4.4
DNSSec=yes
DNSSEC=allow-downgrade
DNS-over-TLS=yes
EOF
    
    sudo systemctl restart systemd-resolved
    
    if command -v resolvectl &> /dev/null; then
        log_info "DNS configuration:"
        resolvectl status || true
    fi
    
    log_info "Encrypted DNS setup complete!"
    press_enter
}

setup_snapshots() {
    log_info "Setting up Snapper for filesystem snapshots..."
    
    log_info "Installing Snapper..."
    sudo apt install -y snapper snapper-gui btrfs-assistant
    
    log_info "Enabling Snapper timers..."
    sudo systemctl enable --now snapper-timeline.timer || true
    sudo systemctl enable --now snapper-cleanup.timer || true
    
    log_warn "Note: Snapper configuration requires btrfs filesystem"
    log_warn "Configure snapshots with: sudo snapper -c root create-config /"
    
    log_info "Snapshots setup complete!"
    press_enter
}

setup_firmware() {
    log_info "Setting up firmware updates..."
    
    log_info "Installing fwupd..."
    sudo apt install -y fwupd
    
    log_info "Refreshing firmware database..."
    sudo fwupdmgr refresh || true
    
    log_info "Checking for firmware updates..."
    sudo fwupdmgr get-updates || true
    
    log_warn "To install firmware updates, run: sudo fwupdmgr update"
    
    log_info "Firmware setup complete!"
    press_enter
}

install_multimedia() {
    log_info "Installing multimedia codecs and support..."
    
    sudo apt install -y \
        libav-tools ffmpeg \
        libavcodec-extra gstreamer1.0-libav \
        opus-tools \
        intel-media-va-driver-non-free
    
    log_info "Multimedia installation complete!"
    press_enter
}

configure_git() {
    log_info "Configuring Git..."
    
    git config --global user.name "Zsolt Aranyi"
    git config --global user.email "aranymedve@gmail.com"
    git config --global init.defaultBranch main
    
    log_info "Copying remmina connection files..."
    mkdir -p "$REMMINA_DIR"
    cp -a "$SCRIPT_DIR/remmina/." "$REMMINA_DIR/" || log_warn "Remmina files not found"
    
    log_info "Copying gamemode configuration..."
    mkdir -p "$GAMEMODE_DIR"
    cp "$SCRIPT_DIR/gamemode.ini" "$GAMEMODE_DIR/gamemode.ini" || log_warn "Gamemode config not found"
    
    log_info "Downloading UpNote AppImage..."
    mkdir -p "$DOWNLOADS_DIR"
    wget -O "$DOWNLOADS_DIR/UpNote.AppImage" https://download.getupnote.com/app/UpNote.AppImage || log_warn "Failed to download UpNote"
    chmod +x "$DOWNLOADS_DIR/UpNote.AppImage"
    
    log_info "Git and config setup complete!"
    press_enter
}

install_calibre() {
    log_info "Installing Calibre eBook Manager..."
    
    sudo -v && wget -nv -O- https://download.calibre-ebook.com/linux-installer.sh | \
        sudo sh /dev/stdin
    
    log_info "Calibre installation complete!"
    press_enter
}

setup_gpg_and_pass() {
    log_info "Setting up GPG keys and password manager..."
    
    log_info "Installing pass (password manager)..."
    sudo apt install -y pass
    
    log_info "Generating GPG keys..."
    TMP_GPGIN=$(mktemp)
    cat << 'EOA' | tee "$TMP_GPGIN"
%echo Generating a default key
Key-Type: RSA
Key-Length: 4096
Subkey-Type: RSA
Subkey-Length: 4096
Name-Real: Zsolt Aranyi
Name-Email: aranymedve@gmail.com
Expire-Date: 0
Passphrase: Medve63383!
%commit
%echo done
EOA
    
    gpg --batch --generate-key "$TMP_GPGIN"
    GPG_KEY=$(gpg --list-secret-keys --keyid-format=long --with-colons | \
        awk -F: '/^sec/ {print $5}' | head -n1)
    
    if [ -n "$GPG_KEY" ]; then
        pass init "$GPG_KEY" || true
        log_info "Password manager initialized with GPG key: $GPG_KEY"
    fi
    
    rm -f "$TMP_GPGIN"
    
    log_info "GPG and password setup complete!"
    press_enter
}

# ============================================================================
# MAIN EXECUTION
# ============================================================================

while true; do
    show_menu
    read -r choice
    
    case $choice in
        1)  setup_system ;;
        2)  install_core_packages ;;
        3)  setup_docker ;;
        4)  install_browsers ;;
        5)  setup_vpn ;;
        6)  setup_flatpak ;;
        7)  setup_power_management ;;
        8)  setup_encrypted_dns ;;
        9)  setup_snapshots ;;
        10) setup_firmware ;;
        11) install_multimedia ;;
        12) configure_git ;;
        13) install_calibre ;;
        14) setup_gpg_and_pass ;;
        15)
            log_info "Running all setup steps..."
            setup_system
            install_core_packages
            install_multimedia
            setup_docker
            install_browsers
            configure_git
            setup_vpn
            setup_flatpak
            setup_power_management
            setup_encrypted_dns
            setup_snapshots
            setup_firmware
            install_calibre
            setup_gpg_and_pass
            log_info "All setup steps completed!"
            press_enter
            ;;
        0)
            log_info "Exiting..."
            exit 0
            ;;
        *)
            log_error "Invalid option. Please try again."
            press_enter
            ;;
    esac
done
