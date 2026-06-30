#!/usr/bin/env bash
# terminal.sh — Install modern terminal tooling (Ubuntu/Debian + Fedora)
# Can be run standalone or sourced by bootstrap.sh
set -euo pipefail

# ---------- helpers ----------
HAS() { command -v "$1" &>/dev/null; }
INFO() { echo -e "\\033[1;34m➜\\033[0m" "$@"; }
OK()   { echo -e "\\033[1;32m✓\\033[0m" "$@"; }
SKIP() { echo -e "\\033[1;33m–\\033[0m" "$@"; }
FAIL() { echo -e "\\033[1;31m✗\\033[0m" "$@"; }

detect_distro() {
  if [[ -f /etc/os-release ]]; then
    . /etc/os-release
    DISTRO="$ID"
    case "$DISTRO" in
      ubuntu|debian|pop|linuxmint|elementary) PKG_MGR="apt" ;;
      fedora|rhel|centos) PKG_MGR="dnf" ;;
      *) PKG_MGR="unknown" ;;
    esac
  else
    PKG_MGR="unknown"
  fi
}

install_pkg() {
  local pkgs=()
  for p in "$@"; do
    if "$PKG_MGR" list --installed 2>/dev/null | grep -qi "^$p"; then
      SKIP "$p already installed"
    else
      pkgs+=("$p")
    fi
  done
  if [[ ${#pkgs[@]} -gt 0 ]]; then
    INFO "Installing: ${pkgs[*]}"
    case "$PKG_MGR" in
      apt) sudo apt install -y "${pkgs[@]}" ;;
      dnf) sudo dnf install -y "${pkgs[@]}" ;;
    esac
  fi
}

install_deb() {
  local name=$1 url=$2
  HAS "$name" && { SKIP "$name"; return; }
  local tmp; tmp=$(mktemp -d)
  curl -fsSL "$url" -o "$tmp/pkg.deb"
  sudo dpkg -i "$tmp/pkg.deb" &>/dev/null && OK "$name installed" || FAIL "$name failed"
  rm -rf "$tmp"
}

install_bin() {
  local name=$1; shift
  HAS "$name" && { SKIP "$name"; return; }
  INFO "Installing $name..."
  "$@" && OK "$name" || FAIL "$name"
}

append_if_missing() {
  local file="$1" text="$2"
  grep -qsxF "$text" "$file" 2>/dev/null || echo "$text" >> "$file"
}

fix_binary_names() {
  mkdir -p "$HOME/.local/bin"
  # fd: Ubuntu ships fdfind, binary is fd everywhere else
  if HAS fdfind && ! HAS fd; then
    ln -sf "$(which fdfind)" "$HOME/.local/bin/fd"
    OK "fd → fdfind symlink"
  fi
  # bat: Ubuntu ships batcat, binary is bat everywhere else
  if HAS batcat && ! HAS bat; then
    ln -sf /usr/bin/batcat "$HOME/.local/bin/bat"
    OK "bat → batcat symlink"
  fi
  export PATH="$HOME/.local/bin:$PATH"
}

# ═══════════════════════════════════════════════════════════════
#  Main
# ═══════════════════════════════════════════════════════════════

detect_distro
INFO "Detected: $DISTRO ($PKG_MGR)"

case "$1" in
  --minimal) MODE="minimal" ;;
  --full)    MODE="full" ;;
  *)         MODE="full" ;;
esac

# ── Base dependencies ──────────────────────────────────────────
install_pkg curl wget git unzip build-essential

# ── Shell & navigation ─────────────────────────────────────────
install_pkg fzf
install_pkg fd-find ripgrep
install_pkg jq

# zoxide
install_bin zoxide bash -c \
  "curl -fsSL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash"

# ── Modern ls / cat replacements ────────────────────────────────
case "$PKG_MGR" in
  apt) install_pkg eza bat ;;
  dnf) install_bin eza bash -c '
        curl -fsSL https://github.com/eza-community/eza/releases/latest/download/eza_x86_64-unknown-linux-gnu.tar.gz \
          | tar xz -C /tmp && sudo mv /tmp/eza /usr/local/bin/'
        install_bin bat bash -c '
        curl -fsSL https://github.com/sharkdp/bat/releases/latest/download/bat-musl_amd64.deb \
          -o /tmp/bat.deb && sudo dpkg -i /tmp/bat.deb'
        ;;
esac
fix_binary_names

# ── Starship prompt ─────────────────────────────────────────────
install_bin starship bash -c \
  "curl -fsSL https://starship.rs/install.sh | sh -s -- -y"

# ── Clipboard (Wayland + X11) ───────────────────────────────────
install_pkg wl-clipboard xclip

# ── System tools ────────────────────────────────────────────────
install_pkg btop htop ncdu

# ── Full mode extras ────────────────────────────────────────────
if [[ "$MODE" == "full" ]]; then
  # lazygit
  install_bin lazygit bash -c '
    LAZYGIT_VERSION=$(curl -s https://api.github.com/repos/jesseduffield/lazygit/releases/latest \
      | grep tag_name | cut -d "\"" -f 4)
    curl -fsLo /tmp/lazygit.tar.gz \
      "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION#v}_Linux_x86_64.tar.gz"
    tar xf /tmp/lazygit.tar.gz -C /tmp
    sudo mv /tmp/lazygit /usr/local/bin/
    rm -f /tmp/lazygit /tmp/lazygit.tar.gz
  '

  # yazi file manager
  install_bin yazi bash -c '
    YAZI_VERSION=$(curl -s https://api.github.com/repos/sxyazi/yazi/releases/latest \
      | grep tag_name | cut -d "\"" -f 4)
    curl -fsLo /tmp/yazi.zip \
      "https://github.com/sxyazi/yazi/releases/latest/download/yazi-x86_64-unknown-linux-gnu.zip"
    unzip -o /tmp/yazi.zip -d /tmp
    sudo mv /tmp/yazi*/yazi /tmp/yazi*/ya /usr/local/bin/
    rm -rf /tmp/yazi*
  '

  # Image preview deps for yazi
  install_pkg ffmpegthumbnailer unar poppler-utils

  # fastfetch
  case "$PKG_MGR" in
    apt) install_deb fastfetch \
         "https://github.com/fastfetch-cli/fastfetch/releases/latest/download/fastfetch-linux-amd64.deb" ;;
    dnf) install_pkg fastfetch ;;
  esac

  # tldr
  install_pkg tldr
  tldr -u 2>/dev/null || true
fi

# ── Shell integration (bashrc) ──────────────────────────────────
append_if_missing "$HOME/.bashrc" 'export PATH="$HOME/.local/bin:$PATH"'
append_if_missing "$HOME/.bashrc" 'alias ls="eza --icons --group-directories-first"'
append_if_missing "$HOME/.bashrc" 'alias ll="eza -lah --icons --git"'
append_if_missing "$HOME/.bashrc" 'alias tree="eza --tree --icons"'
append_if_missing "$HOME/.bashrc" 'alias cat="bat"'
append_if_missing "$HOME/.bashrc" 'eval "$(zoxide init bash)"'
append_if_missing "$HOME/.bashrc" 'eval "$(starship init bash)"'
append_if_missing "$HOME/.bashrc" '[ -f "$HOME/.fzf.bash" ] && source "$HOME/.fzf.bash"'

# FZF defaults
append_if_missing "$HOME/.bashrc" \
  'export FZF_DEFAULT_COMMAND="fd --type f --hidden --exclude .git"'
append_if_missing "$HOME/.bashrc" \
  'export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --border --preview \"bat --color=always {} 2>/dev/null || tree -C {} | head -200\""'

# Cht.sh alias
append_if_missing "$HOME/.bashrc" 'alias cht="curl cht.sh"'

# Smart launcher (fzf + editor)
append_if_missing "$HOME/.bashrc" '
f() {
  local file
  file=$(fd . | fzf --preview "bat --color=always {}") && ${EDITOR:-vim} "$file"
}'

OK "Terminal setup complete."
