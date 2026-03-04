{ config, pkgs, ... }:

{
  home.username = "dCampuzano";
  home.homeDirectory = "/home/dCampuzano";

  home.stateVersion = "24.11";

  home.packages = with pkgs; [
    # Browsers
    google-chrome
    firefox
    
    # Productivity
    libreoffice-fresh
    
    # PDF Tools
    okular
    
    # Communications
    whatsapp-for-linux
    
    # System Utils (User-friendly)
    spectacle # Screenshot
    gwenview # Image viewer
  ];

  # Enable Home Manager to manage itself
  programs.home-manager.enable = true;

  # User-friendly Shell setup
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
  };

  # Simple and clean prompt
  programs.starship = {
    enable = true;
    settings = {
      add_newline = false;
    };
  };
}
