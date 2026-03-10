{ config, pkgs, inputs, ... }:

{
  home.username = "dcampuzano";
  home.homeDirectory = "/home/dcampuzano";

  home.stateVersion = "24.11";

  home.packages = with pkgs; [
    # Browsers
    google-chrome
    
    # Productivity (User Friendly)
    libreoffice-fresh
    pkgs.hunspellDicts.es_MX
    
    # Communications
    whatsapp-for-linux
    telegram-desktop
    
    # Utilities
    gnome-weather
    gnome-maps
    gnome-calculator
    baobab # Disk usage analyzer
    
    # Graphics
    loupe # Modern GNOME image viewer
    evince # PDF viewer
  ];

  # GTK/GNOME Preference
  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
      locate-pointer = true;
    };
    "org/gnome/desktop/wm/preferences" = {
      button-layout = "appmenu:minimize,maximize,close";
    };
  };

  # Enable Home Manager to manage itself
  programs.home-manager.enable = true;

  # Simple and clean bash configuration (don't force ZSH for her)
  programs.bash.enable = true;
}
