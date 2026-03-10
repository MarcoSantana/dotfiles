{ config, pkgs, inputs, ... }:

{
  home.username = "msantana";
  home.homeDirectory = "/home/msantana";

  home.stateVersion = "24.11";

  home.packages = with pkgs; [
    # Admin & Debugging
    git
    wget
    curl
    ripgrep
    fd
    htop
    pciutils
    usbutils
    
    # Simple editor for quick fixes (no Emacs/Neovim setup required here)
    vim
    
    # Modern communication for you
    slack
    discord
  ];

  programs.home-manager.enable = true;

  # Shell configuration for you on the MacBook
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
  };
}
