#!/usr/bin/env bash

# Path to the Hyprland configuration file
HYPR_CONF="$HOME/dotfiles/nixos/home-manager/modules/hyprland.nix"

# Extract keybinds from the module
# This captures bind, bindl, bindel, etc.
binds=$(grep -E "^\s*\"(\$mod|, XF86).*" "$HYPR_CONF" | sed -e 's/^\s*//' -e 's/",//' -e 's/"//g')

# Format the binds for rofi display
echo -e "$binds" | rofi -dmenu -i -p "Hyprland Keybinds:" -theme-str 'window {width: 40%;}'
