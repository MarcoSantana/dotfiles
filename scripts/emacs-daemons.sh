#!/usr/bin/env bash
# emacs-daemons.sh — Install and manage all Emacs flavor daemons
# Usage: emacs-daemons.sh [flavor ...]
#   Flavors: centaur, crafted, doom, spacemacs, firemacs, vanilla
#   --help    Show this message
#   --list    List installed flavors
set -euo pipefail

HAS()        { command -v "$1" &>/dev/null; }
INFO()       { echo -e "\\033[1;34m➜\\033[0m" "$@"; }
OK()         { echo -e "\\033[1;32m✓\\033[0m" "$@"; }
SKIP()       { echo -e "\\033[1;33m–\\033[0m" "$@"; }
FAIL()       { echo -e "\\033[1;31m✗\\033[0m" "$@"; }
SERVICE_DIR="$HOME/.config/systemd/user"

detect_distro() {
  if [[ -f /etc/os-release ]]; then
    . /etc/os-release
    DISTRO="$ID"
  else
    DISTRO="unknown"
  fi
}

install_emacs() {
  HAS emacs && { SKIP "emacs already installed"; return; }
  INFO "Installing Emacs..."
  case "$DISTRO" in
    ubuntu|debian|pop|linuxmint)
      sudo add-apt-repository -y ppa:ubuntu-elisp/ppa 2>/dev/null || true
      sudo apt install -y emacs-gtk emacs-el ;;
    fedora) sudo dnf install -y emacs ;;
    *) sudo apt install -y emacs ;;
  esac
  OK "Emacs installed: $(emacs --version | head -1)"
}

install_service() {
  local name=$1 init_dir=$2 daemon_name=$3
  local unit="$SERVICE_DIR/emacs-${daemon_name}.service"
  mkdir -p "$SERVICE_DIR"
  cat > "$unit" <<UNIT
[Unit]
Description=Emacs Daemon (${daemon_name})

[Service]
Type=forking
ExecStart=/usr/bin/emacs --init-directory ${init_dir} --daemon=${daemon_name}
ExecStop=/usr/bin/emacsclient -s ${daemon_name} --eval "(kill-emacs)"
Restart=always

[Install]
WantedBy=default.target
UNIT
  OK "Service created: $(basename "$unit")"
}

clone_config() {
  local name=$1 repo=$2 dir=$3
  if [[ -d "$dir" ]]; then
    SKIP "$name already cloned at $dir"
    return
  fi
  INFO "Cloning $name from $repo ..."
  git clone --depth 1 "$repo" "$dir" && OK "$name cloned"
}

clone_doom() {
  if [[ -d "$HOME/.emacs.d" ]]; then
    SKIP "Doom already installed"
    return
  fi
  INFO "Installing Doom Emacs..."
  git clone --depth 1 https://github.com/doomemacs/doomemacs "$HOME/.emacs.d"
  "$HOME/.emacs.d/bin/doom install --no-config --no-env" && OK "Doom installed"
}

enable_daemon() {
  local name=$1
  systemctl --user daemon-reload 2>/dev/null
  systemctl --user enable "emacs-${name}" 2>/dev/null
  systemctl --user start "emacs-${name}" 2>/dev/null
  OK "emacs-${name}.service enabled + started"
}

# ═══════════════════════════════════════════════════════════════
#  Main
# ═══════════════════════════════════════════════════════════════

detect_distro
install_emacs

if [[ $# -eq 0 ]]; then
  echo "Usage: $0 [flavor ...]"
  echo "  Flavors: centaur, crafted, doom, spacemacs, firemacs, vanilla"
  echo "  --list  Show installed flavors"
  exit 1
fi

for flavor in "$@"; do
  case "$flavor" in
    --help|-h)
      echo "Usage: $0 [--list | flavor ...]"
      echo "  centaur   https://github.com/seagle0128/.emacs.d"
      echo "  crafted   https://github.com/SystemCrafters/crafted-emacs"
      echo "  doom      https://github.com/doomemacs/doomemacs"
      echo "  spacemacs https://github.com/syl20bnr/spacemacs"
      echo "  firemacs  https://github.com/MarcoSantana/emacs"
      echo "  vanilla   Basic --daemon with no config dir"
      exit 0
      ;;
    --list)
      echo "Installed Emacs flavors:"
      for d in "$HOME"/.emacs.d*; do
        [[ -d "$d" ]] && echo "  $(basename "$d")"
      done
      for s in "$SERVICE_DIR"/emacs-*.service; do
        [[ -f "$s" ]] && echo "  service: $(basename "$s")"
      done
      exit 0
      ;;
    centaur)
      clone_config "Centaur Emacs" \
        "https://github.com/seagle0128/.emacs.d" \
        "$HOME/.emacs.d.centaur"
      install_service "Centaur" "$HOME/.emacs.d.centaur" "centaur"
      enable_daemon "centaur"
      ;;
    crafted)
      clone_config "Crafted Emacs" \
        "https://github.com/SystemCrafters/crafted-emacs" \
        "$HOME/.emacs.d.crafted"
      install_service "Crafted" "$HOME/.emacs.d.crafted" "crafted"
      enable_daemon "crafted"
      ;;
    doom)
      clone_doom
      install_service "Doom" "$HOME/.emacs.d" "doom"
      enable_daemon "doom"
      ;;
    spacemacs)
      clone_config "Spacemacs" \
        "https://github.com/syl20bnr/spacemacs" \
        "$HOME/.emacs.d.spacemacs"
      install_service "Spacemacs" "$HOME/.emacs.d.spacemacs" "spacemacs"
      enable_daemon "spacemacs"
      ;;
    firemacs)
      clone_config "Firemacs" \
        "https://github.com/MarcoSantana/emacs" \
        "$HOME/.emacs.d.firemacs"
      install_service "Firemacs" "$HOME/.emacs.d.firemacs" "firemacs"
      # Firemacs needs nvm in PATH
      local nvm_node
      nvm_node="$(find "$HOME/.nvm/versions/node" -maxdepth 2 -name bin -type d 2>/dev/null | head -1)"
      if [[ -n "$nvm_node" ]]; then
        sed -i "/^ExecStart/i\\Environment=PATH=${nvm_node}:/usr/local/bin:/usr/bin:/bin" \
          "$SERVICE_DIR/emacs-firemacs.service"
      fi
      enable_daemon "firemacs"
      ;;
    vanilla)
      install_service "Vanilla" "$HOME/.emacs.d" "vanilla"
      enable_daemon "vanilla"
      ;;
    *)
      FAIL "Unknown flavor: $flavor"
      exit 1
      ;;
  esac
done

OK "Emacs daemons ready."
