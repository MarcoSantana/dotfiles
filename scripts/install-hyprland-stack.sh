#!/usr/bin/env bash
# install-hyprland-stack.sh — Finish what bootstrap --full couldn't (spinner TTY bug)
set -euo pipefail

echo "=== 1/6 Add Hyprland PPA ==="
sudo add-apt-repository -y ppa:cppiber/hyprland
sudo apt-get update -qq

echo "=== 2/6 Install Hyprland + desktop stack ==="
sudo apt-get install -y \
  hyprland hyprpaper hyprlock hypridle \
  sddm \
  pipewire pipewire-pulse pipewire-audio wireplumber pavucontrol \
  network-manager-gnome blueman \
  cups system-config-printer \
  xdg-desktop-portal-hyprland xdg-desktop-portal-gtk \
  grim slurp wl-clipboard \
  wdisplays wlr-randr \
  qt5ct qt6ct \
  brightnessctl playerctl \
  upower power-profiles-daemon \
  thunar gvfs thunar-volman udisks2 \
  fonts-font-awesome \
  policykit-1-gnome \
  waybar rofi fuzzel uwsm

echo "=== 2b/6 Optional extras (swaync, swappy, nwg-look) ==="
# swaync — install via GitHub release
if ! command -v swaync &>/dev/null; then
  echo "  → Installing swaync from GitHub..."
  cd /tmp
  url=$(curl -fsSL https://api.github.com/repos/ErikReider/SwayNotificationCenter/releases/latest \
    | grep "browser_download_url.*x86_64-linux-gnu" | cut -d'"' -f4)
  wget -q "$url" -O swaync.tar.gz && \
  tar xzf swaync.tar.gz && \
  sudo install -m755 swaync/swaync /usr/local/bin/ && \
  rm -rf swaync* && \
  echo "  ✓ swaync" || echo "  ⚠ swaync install failed"
fi

# swappy, nwg-look — skipped (build from source or manual install)
echo "  → swappy and nwg-look not in repos — install manually if needed:"
echo "    swappy:   https://github.com/jtheoof/swappy"
echo "    nwg-look: https://github.com/nwg-piotr/nwg-look"

echo "=== 3/6 Enable services ==="
# SDDM skipped on live systems (COSMIC greeter already in place).
# Fresh installs: bootstrap.sh handles sddm enable.
if ! systemctl is-enabled display-manager &>/dev/null; then
  sudo systemctl enable sddm
else
  echo "  → Display manager already active ($(readlink /etc/systemd/system/display-manager.service 2>/dev/null || echo 'unknown'))"
fi
sudo systemctl enable bluetooth
sudo systemctl enable cups
sudo systemctl enable power-profiles-daemon
systemctl --user enable --now pipewire pipewire-pulse wireplumber 2>/dev/null || true

echo "=== 4/6 Resolve stow conflicts ==="
cd ~/dotfiles
# Back up any real files that stow wants to symlink, so stow doesn't abort
for link in .zshrc .bashrc .bash_profile .gitconfig .vimrc; do
  if [[ -f "$HOME/$link" && ! -L "$HOME/$link" ]]; then
    bak="$HOME/$link.bak.$(date +%s)"
    mv "$HOME/$link" "$bak" && echo "  → backed up $link → $(basename $bak)"
  fi
done

echo "=== 5/6 Apply stow ==="
stow -R hypr rofi kitty eww git ghostty zsh bash
mkdir -p ~/.local/bin
ln -sf ~/dotfiles/scripts/theme-switch.sh ~/.local/bin/theme-switch
ln -sf ~/dotfiles/scripts/dotfiles.sh ~/.local/bin/dotfiles
git config core.hooksPath ~/dotfiles/.githooks
echo "  ✓ Stow applied"

echo "=== 6/6 Verify ==="
echo ""
echo "  Hyprland:  $(command -v Hyprland || echo MISSING)"
echo "  SDDM:      $(systemctl is-enabled sddm 2>/dev/null || echo NOT FOUND)"
echo "  Waybar:    $(command -v waybar || echo MISSING)"
echo "  Session:   $(ls ~/.local/share/wayland-sessions/hyprland.desktop 2>/dev/null || echo MISSING)"
echo "  Stow:      $(ls -la ~/.config/hypr/hyprland.conf 2>/dev/null || echo NOT STOWED)"
echo ""
echo "Done. Reboot and pick Hyprland at SDDM login."
echo "After login, run 'theme-switch' to set your colors."
