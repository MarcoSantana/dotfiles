# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:


{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

    nix = {
        package = pkgs.nixFlakes;
        extraOptions = ''
          experimental-features = nix-command flakes
        '';
    };
  # nixpkgs.overlays = [ (import self.inputs.emacs-overlay) ];
  # Overlays are now handled in flake.nix
  # Bootloader.
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/vda";
  boot.loader.grub.useOSProber = true;

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

  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  # Enable EXWM
  services.xserver.windowManager.exwm.enable = true;
  services.xserver.displayManager.defaultSession = "nixos-exwm";

  # Configure keymap in X11
  services.xserver = {
    layout = "us";
    xkbVariant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  sound.enable = true;
  hardware.pulseaudio.enable = false;
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
    extraGroups = [ "networkmanager" "wheel" ];
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
      firefox
      chromium
      google-chrome
      brave
      microsoft-edge
      vscodium
      gitnuro
      dbeaver
      ngrok

      # Development Environments
      # Node.js
      nodejs
      nodePackages_latest.pnpm
      nodePackages.typescript
      nodePackages_latest.vue-language-server
      nodePackages_latest.vue-cli

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
      python3Full
      python311Packages.pip

      # Go
      go

      # Modern Nix Tools
      nh
    ];
  };

  # Enable automatic login for the user.
  services.xserver.displayManager.autoLogin.enable = true;
  services.xserver.displayManager.autoLogin.user = "msantana";

  # Workaround for GNOME autologin: https://github.com/NixOS/nixpkgs/issues/103746#issuecomment-945091229
  systemd.services."getty@tty1".enable = false;
  systemd.services."autovt@tty1".enable = false;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

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
    (nerdfonts.override { fonts = [ "JetBrainsMono" "FiraCode" ]; })
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
