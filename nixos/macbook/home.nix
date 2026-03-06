{ config, pkgs, inputs, ... }:

{
  home.username = "dcampuzano";
  home.homeDirectory = "/home/dcampuzano";

  home.stateVersion = "24.11";

  home.packages = with pkgs; [
    # Browsers
    google-chrome
    firefox
    
    # Productivity
    libreoffice-fresh
    
    # PDF Tools
    pkgs.kdePackages.okular
    
    # Communications
    pkgs.whatsapp-electron
    
    # System Utils (User-friendly)
    pkgs.kdePackages.spectacle # Screenshot
    pkgs.kdePackages.gwenview # Image viewer
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
