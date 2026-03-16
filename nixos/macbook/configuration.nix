# Version: 2026-11-01
{ config, pkgs, inputs, ... }:

{
  imports = [
    # Hardware configuration will be generated on the device and imported here
    ./hardware-configuration.nix
    ../common.nix
  ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot";
  
  # Explicitly disable GRUB to prevent conflicts
  boot.loader.grub.enable = false;
  # Prevent any accidental GRUB installation to a generic device
  boot.loader.grub.device = "nodev";

  networking.hostName = "macbook"; # Define your hostname.
  
  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "America/Mexico_City"; # Adjust as needed

  # Select internationalisation properties.
  i18n.defaultLocale = "es_MX.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "es_MX.UTF-8";
    LC_IDENTIFICATION = "es_MX.UTF-8";
    LC_MEASUREMENT = "es_MX.UTF-8";
    LC_MONETARY = "es_MX.UTF-8";
    LC_NAME = "es_MX.UTF-8";
    LC_NUMERIC = "es_MX.UTF-8";
    LC_PAPER = "es_MX.UTF-8";
    LC_TELEPHONE = "es_MX.UTF-8";
    LC_TIME = "es_MX.UTF-8";
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable GNOME desktop environment
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "latam"; # Latin American layout is usually better for MX MacBooks
    variant = "";
    options = "ctrl:nocaps,compose:ralt";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # --- MacBook Specific Hardware Support ---
  
  nixpkgs.config.permittedInsecurePackages = [
    "broadcom-sta-6.30.223.271-59-6.12.74"
  ];

  # Broadcom STA Driver
  boot.extraModulePackages = [ config.boot.kernelPackages.broadcom_sta ];
  boot.initrd.kernelModules = [ "wl" ];
  boot.blacklistedKernelModules = [ "b43" "ssb" "bcma" ];

  # Intelligent Fan Control for MacBook
  services.mbpfan.enable = true;

  # Power Management and Heat Control
  services.tlp.enable = true;
  services.thermald.enable = true;
  services.power-profiles-daemon.enable = pkgs.lib.mkForce false; # Conflicts with TLP

  # Backlight control
  programs.light.enable = true;

  # Better Trackpad Experience
  services.libinput = {
    enable = true;
    touchpad = {
      tapping = true;
      naturalScrolling = true;
      clickMethod = "clickfinger";
    };
  };

  # Graphics Acceleration
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  # --- User Configuration ---

  users.users.dcampuzano = {
    isNormalUser = true;
    description = "Danelia Campuzano";
    extraGroups = [ "networkmanager" "wheel" "lp" "scanner" "video" ];
  };

  # Admin user (You)
  users.users.msantana = {
    isNormalUser = true;
    description = "Marco Santana (Admin)";
    extraGroups = [ "networkmanager" "wheel" "docker" ];
  };

  # --- System Packages & Fonts ---
  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    nerd-fonts.roboto-mono
    google-fonts
    corefonts # Microsoft fonts for LibreOffice compatibility
    vistafonts # Calibri, etc.
  ];

  environment.systemPackages = with pkgs; [
    # Core Utilities
    vim
    wget
    git
    sbctl
    
    # GNOME Goodies
    gnome-tweaks
    gnome-extension-manager
    
    # Productivity (System-wide)
    libreoffice-fresh
    hunspell
    hunspellDicts.es_MX
    hunspellDicts.en_US
    hyphen
    aspell
    aspellDicts.es
    
    # Graphics/PDF
    evince
    eog
    gimp
  ];

  system.stateVersion = "24.11"; # Did you read the comment?
}
