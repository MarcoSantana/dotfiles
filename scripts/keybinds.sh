#!/usr/bin/env bash

# Path to the home.nix file containing keybinds
HOME_NIX="$HOME/dotfiles/nixos/home-manager/home.nix"

# Extract keybinds from home.nix
# This looks for the bind lines in the Hyprland configuration
binds=$(grep -E "^\s*\"\$mod.*" "$HOME_NIX" | sed -e 's/^\s*//' -e 's/",//' -e 's/"//g')

# Format the binds for rofi display
echo -e "$binds" | rofi -dmenu -i -p "Hyprland Keybinds:" -theme-str 'window {width: 40%;}'
