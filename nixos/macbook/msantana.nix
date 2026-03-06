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

  # Map Caps Lock to Ctrl in GNOME
  dconf.settings = {
    "org/gnome/desktop/input-sources" = {
      xkb-options = [ "ctrl:nocaps" ];
    };
  };

  # Map Caps Lock to Ctrl in Hyprland
  wayland.windowManager.hyprland = {
    settings = {
      input = {
        kb_options = "ctrl:nocaps";
      };
    };
  };
}
