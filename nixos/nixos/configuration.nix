# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, inputs, ... }:


{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

    nix = {
        package = pkgs.nix;
        settings.experimental-features = [ "nix-command" "flakes" ];
    };
  # nixpkgs.overlays = [ (import self.inputs.emacs-overlay) ];
  # Overlays are now handled in flake.nix
  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";

  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "America/Mexico_City";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable GNOME Desktop Environment.
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;

  # Enable Hyprland
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  services.displayManager.defaultSession = "hyprland";

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  # sound.enable = true; # Deprecated in favor of services.pipewire
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  services.emacs = {
    enable = true;
    package = pkgs.emacs-unstable; # From overlay
  };

  # Define a user account.
  users.users.msantana = {
    isNormalUser = true;
    description = "Marco A. Santana";
    packages = with pkgs; [
      # Base Tools
      git
      wget
      ripgrep
      unzip
      kitty
      kitty-themes
      ghostty # Ghostty terminal
      ranger
      byobu
      sqlite
      cmake
      maestral
      maestral-gui
      logseq
      syncthing

      # Desktop Apps
      vscodium
      gitnuro
      dbeaver-bin
      ngrok

      # Development Environments
      # Node.js
      nodejs
      nodePackages_latest.pnpm
      nodePackages.typescript
      vue-language-server

      # PHP (Updated to 8.3)
      php83
      php83Packages.composer

      # Ruby on Rails
      ruby_3_3
      bundler
      # rails is usually installed via gem, but we can add the package if needed
      # (pkgs.rubyPackages_3_3.rails if available, otherwise just use bundler)

      # Clojure
      clojure
      leiningen
      babashka
      clojure-lsp

      # Python
      python3
      python311Packages.pip

      # Go
      go

      # Advanced IDEs
      lapce

      # Modern Nix Tools
      nh

      # System TUI Tools
      bandwhich
      gdu
      trippy
    ];
  };

  # Enable automatic login for the user.
  services.displayManager.autoLogin.enable = true;
  services.displayManager.autoLogin.user = "msantana";

  # Workaround for GNOME autologin: https://github.com/NixOS/nixpkgs/issues/103746#issuecomment-945091229
  systemd.services."getty@tty1".enable = false;
  systemd.services."autovt@tty1".enable = false;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.permittedInsecurePackages = [
    "electron-27.3.11"
  ];

  # Home Manager Configuration is now handled in flake.nix (handled as a module)

  # List packages installed in system profile.
  environment.systemPackages = with pkgs; [
    neovim
    wget
    git
    emacs-unstable # From overlay
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Enable Syncthing
  services.syncthing = {
    enable = true;
    user = "msantana";
    dataDir = "/home/msantana";
    configDir = "/home/msantana/.config/syncthing";
  };

  # Enable Tailscale
  services.tailscale.enable = true;

  # Enable Docker
  virtualisation.docker.enable = true;
  users.users.msantana.extraGroups = [ "networkmanager" "wheel" "docker" ];

  # Fonts
  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    nerd-fonts.fira-code
  ];

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?

}
