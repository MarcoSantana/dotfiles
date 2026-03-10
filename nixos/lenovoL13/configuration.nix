{ config, pkgs, inputs, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  # Use systemd-boot for EFI
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot";

  networking.hostName = "lenovoL13";
  networking.networkmanager.enable = true;

  time.timeZone = "America/Mexico_City";
  i18n.defaultLocale = "en_US.UTF-8";

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable GNOME (as a fallback or for shared sessions)
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
    options = "ctrl:nocaps,compose:ralt";
  };

  # Set Hyprland as default session
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };
  services.displayManager.defaultSession = "hyprland";

  # Laptop specific services
  services.thermald.enable = true;
  services.tlp = {
    enable = true; # Power management
    settings = {
      START_CHARGE_THRESH_BAT0 = 75;
      STOP_CHARGE_THRESH_BAT0 = 100; # Allow full charge
      START_CHARGE_THRESH_BAT1 = 75;
      STOP_CHARGE_THRESH_BAT1 = 100;
    };
  };
  services.power-profiles-daemon.enable = pkgs.lib.mkForce false; # Conflicts with TLP
  services.upower.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Define user
  users.users.msantana = {
    isNormalUser = true;
    description = "Marco A. Santana";
    extraGroups = [ "networkmanager" "wheel" "docker" "video" "input" ];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    vim
    wget
    git
    brightnessctl
    tlp
    hunspell
    hunspellDicts.es_MX
    hunspellDicts.en_US
  ];

  # Enable Docker
  virtualisation.docker.enable = true;

  system.stateVersion = "24.11";
}
