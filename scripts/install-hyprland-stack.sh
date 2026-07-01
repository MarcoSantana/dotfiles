#!/usr/bin/env bash
# install-hyprland-stack.sh — Finish what bootstrap --full couldn't (spinner TTY bug)
set -euo pipefail

echo "=== 1/6 Add Hyprland PPA ==="
sudo add-apt-repository -y ppa:cppiber/hyprland
sudo apt-get update -qq

echo "=== 2/6 Install Hyprland + desktop stack ==="
sudo apt-get install -y \
  hyprland hyprpaper hyprlock hypridle \
  sddm swaync \
  pipewire pipewire-pulse pipewire-audio wireplumber pavucontrol \
  network-manager-gnome blueman \
  cups system-config-printer \
  xdg-desktop-portal-hyprland xdg-desktop-portal-gtk \
  grim slurp swappy wl-clipboard \
  wdisplays wlr-randr nwg-look \
  qt5ct qt6ct \
  brightnessctl playerctl \
  upower power-profiles-daemon \
  thunar gvfs thunar-volman udisks2 \
  fonts-font-awesome \
  policykit-1-gnome \
  waybar rofi

echo "=== 3/6 Enable services ==="
sudo systemctl enable sddm
sudo systemctl enable bluetooth
sudo systemctl enable cups
sudo systemctl enable power-profiles-daemon
systemctl --user enable --now pipewire pipewire-pulse wireplumber 2>/dev/null || true

echo "=== 4/6 Apply stow ==="
cd ~/dotfiles
stow -R hypr rofi kitty eww git ghostty zsh bash
mkdir -p ~/.local/bin
ln -sf ~/dotfiles/scripts/theme-switch.sh ~/.local/bin/theme-switch
ln -sf ~/dotfiles/scripts/dotfiles.sh ~/.local/bin/dotfiles
git config core.hooksPath ~/dotfiles/.githooks
echo "  ✓ Stow applied"

echo "=== 5/5 Verify ==="
echo ""
echo "  Hyprland:  $(command -v Hyprland || echo MISSING)"
echo "  SDDM:      $(systemctl is-enabled sddm 2>/dev/null || echo NOT FOUND)"
echo "  Waybar:    $(command -v waybar || echo MISSING)"
echo "  Session:   $(ls ~/.local/share/wayland-sessions/hyprland.desktop 2>/dev/null || echo MISSING)"
echo "  Stow:      $(ls -la ~/.config/hypr/hyprland.conf 2>/dev/null || echo NOT STOWED)"
echo ""
echo "Done. Reboot and pick Hyprland at SDDM login."
echo "After login, run 'theme-switch' to set your colors."
