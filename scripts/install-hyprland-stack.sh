#!/usr/bin/env bash
set -euo pipefail

echo "=== 1/6 Add Hyprland PPA ==="
sudo add-apt-repository -y ppa:hyprland/ppa
sudo apt-get update -qq

echo "=== 2/6 Install Hyprland + desktop stack ==="
sudo apt-get install -y hyprland sddm swaync pipewire wireplumber \
  pipewire-pulse nm-applet blueman cups xdg-desktop-portal-hyprland \
  grim slurp swappy wl-clipboard cliphist wdisplays nwg-look \
  qt5ct qt6ct brightnessctl playerctl upower thunar gvfs \
  fonts-font-awesome polkit-gnome rofi waybar

echo "=== 3/6 Enable services ==="
sudo systemctl enable sddm
sudo systemctl enable bluetooth
sudo systemctl enable cups
systemctl --user enable --now pipewire pipewire-pulse wireplumber 2>/dev/null || true

echo "=== 4/6 Add Hyprland session ==="
mkdir -p ~/.local/share/wayland-sessions
cat > ~/.local/share/wayland-sessions/hyprland.desktop << 'EOF'
[Desktop Entry]
Name=Hyprland
Comment=Hyprland Wayland compositor
Exec=Hyprland
Type=Application
EOF

echo "=== 5/6 Apply stow ==="
cd ~/dotfiles
stow -R hypr
stow -R rofi
stow -R kitty
stow -R eww
stow -R git
stow -R ghostty
stow -R zsh
stow -R bash

# Link CLI tools
mkdir -p ~/.local/bin
ln -sf ~/dotfiles/scripts/theme-switch.sh ~/.local/bin/theme-switch
ln -sf ~/dotfiles/scripts/dotfiles.sh ~/.local/bin/dotfiles

# Git hooks
git config core.hooksPath ~/dotfiles/.githooks

echo "=== 6/6 Verify ==="
echo "Hyprland: $(command -v Hyprland || echo MISSING)"
echo "SDDM: $(systemctl is-enabled sddm 2>/dev/null || echo NOT FOUND)"
echo "Session file: $(ls -la ~/.local/share/wayland-sessions/hyprland.desktop 2>/dev/null || echo MISSING)"
echo ""
echo "Done. Reboot and pick Hyprland at login."
