{ config, pkgs, lib, ... }:

{
  imports = [
    ./hardware-configuration.nix
    # Optionally add nixos-hardware ThinkPad module if available
    # For flakes: nixos-hardware input for lenovo-thinkpad
  ];

  boot.kernelPackages = pkgs.linuxPackages_latest;

  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  time.timeZone = "Europe/Budapest";
  i18n.defaultLocale = "en_US.UTF-8";
  console.keyMap = "us";

  networking.hostName = "thinkpad-t495";
  networking.networkmanager.enable = true;

  nixpkgs.config = {
    allowUnfree = true;
    hardware.enableRedistributableFirmware = true;
  };

  services.xserver = {
    enable = true;
    displayManager.sddm.enable = true;
    desktopManager.plasma5.enable = true;

    xkb = {
      layout = "us";
      variant = "";
    };

    displayManager.sddm.wayland.enable = true;
  };

  sound.enable = true;
  hardware.pulseaudio.enable = false;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };

  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  powerManagement.enable = true;
  services.tlp.enable = true;

  services.logind = {
    lidSwitch = "suspend";
    lidSwitchDocked = "ignore";
  };

  services.printing.enable = true;
  hardware.sane.enable = true;

  environment.systemPackages = with pkgs; [
    firefox
    docker
    openvpn
    git
    vim
    wget
    curl
    htop
    tlp
    powertop
    kdePackages.kate
    kdePackages.kcalc
    kdePackages.konsole
  ];

  users.users.alex = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "docker" "audio" "video" "lp" "scanner" ];
    initialPassword = "changeme"; # Change this and remove later
    openssh.authorizedKeys.keys = [
      # Add your ssh public keys here
    ];
  };

  security.sudo.wheelNeedsPassword = true;

  services.openssh.enable = false;

  systemd.services.docker = {
    description = "Docker Service";
    after = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
  };

  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    auto-optimise-store = true;
  };

  system.stateVersion = "24.11"; # Set to your installed NixOS version
}
