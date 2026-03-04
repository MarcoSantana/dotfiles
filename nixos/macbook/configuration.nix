{ config, pkgs, inputs, ... }:

{
  imports = [
    # Hardware configuration will be generated on the device and imported here
    ./hardware-configuration.nix
  ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

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

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  hardware.pulseaudio.enable = false;
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

  # Broadcom STA Driver
  boot.extraModulePackages = [ config.boot.kernelPackages.broadcom_sta ];
  boot.initrd.kernelModules = [ "wl" ];
  boot.blacklistedKernelModules = [ "b43" "ssb" "bcma" ];

  # --- User Configuration ---

  users.users.dCampuzano = {
    isNormalUser = true;
    description = "Danelia Campuzano";
    extraGroups = [ "networkmanager" "wheel" "lp" "scanner" ];
  };

  # --- System Packages ---
  environment.systemPackages = with pkgs; [
    vim
    wget
    git
    sbctl # Secure boot tools if needed
  ];

  system.stateVersion = "24.11"; # Did you read the comment?
}
