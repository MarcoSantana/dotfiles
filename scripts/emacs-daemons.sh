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

# ── Helper: flavor → repo URL ──────────────────────────────────────
repo_of() {
  case "$1" in
    centaur)  echo "https://github.com/seagle0128/.emacs.d" ;;
    crafted)  echo "https://github.com/SystemCrafters/crafted-emacs" ;;
    doom)     echo "https://github.com/doomemacs/doomemacs" ;;
    spacemacs) echo "https://github.com/syl20bnr/spacemacs" ;;
    firemacs) echo "https://github.com/MarcoSantana/emacs" ;;
    vanilla)  echo "" ;;
  esac
}
dir_of() {
  case "$1" in
    centaur)  echo "$HOME/.emacs.d.centaur" ;;
    crafted)  echo "$HOME/.emacs.d.crafted" ;;
    doom)     echo "$HOME/.emacs.d" ;;
    spacemacs) echo "$HOME/.emacs.d.spacemacs" ;;
    firemacs) echo "$HOME/.emacs.d.firemacs" ;;
    vanilla)  echo "$HOME/.emacs.d" ;;
  esac
}

# ── clone-only action (used by bootstrap.sh for parallel clones) ──
if [[ "$1" == "clone-only" ]]; then
  flavor="$2"
  case "$flavor" in
    doom) clone_doom ;;
    *)
      dir=$(dir_of "$flavor")
      [[ -d "$dir" ]] && { SKIP "$flavor already cloned at $dir"; exit 0; }
      repo=$(repo_of "$flavor")
      clone_config "$flavor" "$repo" "$dir"
      ;;
  esac
  exit 0
fi

for flavor in "$@"; do
  case "$flavor" in
    --help|-h)
      echo "Usage: $0 [--list | clone-only FLAVOR | FLAVOR ...]"
      echo "  clone-only FLAVOR  Clone repo only (no service, no daemon)"
      echo "  --list             List installed flavors"
      echo ""
      echo "Flavors:"
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
    centaur|crafted|doom|spacemacs|firemacs|vanilla)
      dir=$(dir_of "$flavor")
      repo=$(repo_of "$flavor")
      if [[ "$flavor" != "doom" && "$flavor" != "vanilla" ]]; then
        clone_config "$flavor" "$repo" "$dir"
      elif [[ "$flavor" == "doom" ]]; then
        clone_doom
      fi
      install_service "$flavor" "$dir" "$flavor"
      # Firemacs needs nvm in PATH
      if [[ "$flavor" == "firemacs" ]]; then
        nvm_node="$(find "$HOME/.nvm/versions/node" -maxdepth 2 -name bin -type d 2>/dev/null | head -1)"
        if [[ -n "$nvm_node" ]]; then
          sed -i "/^ExecStart/i\\Environment=PATH=${nvm_node}:/usr/local/bin:/usr/bin:/bin" \
            "$SERVICE_DIR/emacs-firemacs.service"
        fi
      fi
      enable_daemon "$flavor"
      ;;
    *)
      FAIL "Unknown flavor: $flavor"
      exit 1
      ;;
  esac
done

OK "Emacs daemons ready."
