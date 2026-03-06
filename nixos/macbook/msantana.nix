{ config, pkgs, inputs, ... }:

{
  home.username = "msantana";
  home.homeDirectory = "/home/msantana";

  home.stateVersion = "24.11";

  home.packages = with pkgs; [
    git
    # Gnome desktop is enabled in configuration.nix system-wide
  ];

  programs.home-manager.enable = true;
}
