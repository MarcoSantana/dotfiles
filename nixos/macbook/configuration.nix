{ config, pkgs, inputs, ... }:

{
  imports = [
    # Hardware configuration will be generated on the device and imported here
    ./hardware-configuration.nix
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
  i18n.defaultLocale = "en_US.UTF-8";

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the KDE Plasma Desktop Environment.
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;

  # Enable GNOME desktop environment
  services.desktopManager.gnome.enable = true;

  # Resolve ssh-askpass conflict between Plasma and GNOME
  programs.ssh.askPassword = pkgs.lib.mkForce "${pkgs.kdePackages.ksshaskpass}/bin/ksshaskpass";

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
    options = "ctrl:nocaps,compose:ralt";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

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
  
  # Allow unfree for Broadcom drivers
  nixpkgs.config.allowUnfree = true;
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
    extraGroups = [ "networkmanager" "wheel" "lp" "scanner" ];
  };

  users.users.msantana = {
    isNormalUser = true;
    description = "Marco Santana";
    extraGroups = [ "networkmanager" "wheel" ];
  };

  # --- System Packages ---
  environment.systemPackages = with pkgs; [
    vim
    wget
    git
    sbctl # Secure boot tools if needed
    hunspell
    hunspellDicts.es_MX
    hunspellDicts.en_US
  ];

  system.stateVersion = "24.11"; # Did you read the comment?
}
