#!/usr/bin/env bash
#
# bootstrap.sh — Interactive Ubuntu/Debian dotfiles installer
# Uses gum for a pretty TUI. You choose what goes in.
#
set -euo pipefail

DOTFILES="$HOME/dotfiles"
DRY_RUN=false

# ── Parse args ───────────────────────────────────────────────────────
while [[ $# -gt 0 ]]; do
  case $1 in --dry-run) DRY_RUN=true ;; --help|-h)
    echo "Usage: $0 [--dry-run]"; exit 0 ;;
  *) echo "Unknown: $1"; exit 1 ;; esac; shift
done

run() {
  if $DRY_RUN; then echo "[DRY-RUN] $*"; else "$@"; fi
}

# ── Bootstrap gum itself (needed for the whole TUI) ──────────────────
if ! command -v gum &>/dev/null; then
  echo "Installing gum for the pretty TUI..."
  mkdir -p /tmp/gum
  curl -fsSL https://github.com/charmbracelet/gum/releases/latest/download/gum_amd64.deb \
    -o /tmp/gum/gum.deb
  sudo dpkg -i /tmp/gum/gum.deb &>/dev/null
  rm -rf /tmp/gum
fi

# ── Gum helpers ──────────────────────────────────────────────────────
header()    { gum style --border thick --padding "1 2" --margin "0 0 1 0" "$1"; }
subheader() { gum style --padding "0 1" --foreground 212 "$1"; }
ok()        { gum style --foreground 42 "$1"; }
warn()      { gum style --foreground 220 "$1"; }
fail()      { gum style --foreground 196 "$1"; exit 1; }
prompt()    { gum input --placeholder "$1" --value "${2:-}" --width 60; }
confirm()   { gum confirm --affirmative "Yes" --negative "No" "$1"; }
spinner()   { gum spin --spinner dot --title "$1" -- "$2"; }

# ── Preflight ────────────────────────────────────────────────────────
header "Preflight"

if [[ ! -f /etc/os-release ]]; then
  fail "Cannot detect OS. This script targets Debian/Ubuntu."
fi
. /etc/os-release
if [[ "$ID" =~ ^(ubuntu|debian|pop|linuxmint|elementary)$ ]]; then
  ok "Detected: $ID $VERSION_ID ($VERSION_CODENAME)"
else
  warn "Untested distro: $ID (proceed at your own risk)"
  confirm "Continue?" || exit 1
fi

if [[ ! -d "$DOTFILES/.git" ]]; then
  fail "No git repo at $DOTFILES — clone your dotfiles first."
fi
ok "Dotfiles repo: $DOTFILES"

# ── Welcome ──────────────────────────────────────────────────────────
gum style \
  --border double --border-foreground 212 \
  --padding "1 3" --margin "1 0" \
  "  .--.  v2  Ubuntu/Debian Bootstrap
 /     \  Pick what you need —
 \ .-. /  skip the rest.
  \_/_/   " | gum format -t emoji

confirm "Start the bootstrap?" || exit 1

# ── Category selections ──────────────────────────────────────────────
choose() {
  gum choose --no-limit --header "$1" --cursor "➜ " --selected-prefix "✓ " --unselected-prefix "• " "${@:2}"
}

header "Select what to install"

# --- Category: Core System ---
subheader "Core System"
CORE=$(choose "Essentials (always recommended)" \
  "curl,wget,git" \
  "build-essential" \
  "stow" \
  "unzip,xclip" \
  "fira-code,fonts-noto-color-emoji" \
  "fonts-symbola")

# --- Category: Shell & Terminal ---
subheader "Shell & Terminal"
SHELL_ITEMS=$(choose "Shell tools" \
  "zsh" \
  "tmux" \
  "fzf" \
  "fd-find,ripgrep" \
  "eza (modern ls)" \
  "bat (modern cat)" \
  "jq" \
  "starship prompt" \
  "zoxide (smarter cd)" \
  "fastfetch" \
  "oh-my-zsh" \
  "kitty terminal" \
  "grip (markdown preview)" \
  "shellcheck,shfmt")

# --- Category: Editors ---
subheader "Editors"
EDITORS=$(choose "Pick your weapons" \
  "neovim" \
  "helix" \
  "zed" \
  "emacs (doom)" \
  "emacs (firemacs)" \
  "vim")

# --- Category: Desktop / WM ---
subheader "Desktop / Window Manager"
DESKTOP=$(choose "Desktop components" \
  "i3 window manager" \
  "rofi launcher" \
  "eww widgets" \
  "waybar" \
  "hyprland" \
  "screenshot tools (maim, scrot, grim, slurp)")

# --- Category: Development ---
subheader "Development"
DEV=$(choose "Dev tooling" \
  "nvm (node version manager)" \
  "mise (runtime version manager)" \
  "podman + podman-docker" \
  "docker.io" \
  "clojure tools (clj-kondo, cljfmt)" \
  "stylelint, js-beautify, tidy")

# --- Category: Dotfiles (Stow) ---
header "Dotfiles (Stow packages)"

AVAILABLE_STOW=()
for d in "$DOTFILES"/*/; do
  name=$(basename "$d")
  [[ "$name" == .git || "$name" == nixos || "$name" == assets ]] && continue
  AVAILABLE_STOW+=("$name")
done

STOW_SELECTED=()
while IFS= read -r line; do
  STOW_SELECTED+=("$line")
done < <(
  gum choose --no-limit \
    --header "Which configs to stow? (↑↓ navigate, space toggle, enter confirm)" \
    --cursor "➜ " \
    --selected-prefix "✓ " \
    --unselected-prefix "• " \
    "${AVAILABLE_STOW[@]}"
)

if [[ ${#STOW_SELECTED[@]} -eq 0 ]]; then
  warn "No stow packages selected — skipping dotfiles deployment."
fi

# ── Confirmation ─────────────────────────────────────────────────────
header "Summary"
echo
gum style --foreground 212 "Core:    $(IFS=,; echo "${CORE[*]}" | tr '\n' ' ')"
gum style --foreground 212 "Shell:   $(IFS=,; echo "${SHELL_ITEMS[*]}" | tr '\n' ' ')"
gum style --foreground 212 "Editors: $(IFS=,; echo "${EDITORS[*]}" | tr '\n' ' ')"
gum style --foreground 212 "Desktop: $(IFS=,; echo "${DESKTOP[*]}" | tr '\n' ' ')"
gum style --foreground 212 "Dev:     $(IFS=,; echo "${DEV[*]}" | tr '\n' ' ')"
gum style --foreground 212 "Stow:    ${STOW_SELECTED[*]}"
echo
confirm "Proceed with install?" || exit 1

# ── APT Install ──────────────────────────────────────────────────────
install_apt() {
  local pkgs=()
  for p in "$@"; do pkgs+=("$p"); done
  if [[ ${#pkgs[@]} -gt 0 ]]; then
    export DEBIAN_FRONTEND=noninteractive
    spinner "Installing APT packages..." \
      "sudo apt-get install -y -qq ${pkgs[*]}"
  fi
}

header "Installation"

# Update once
export DEBIAN_FRONTEND=noninteractive
spinner "Updating package lists..." "sudo apt-get update -qq"

# --- Core ---
APT_CORE=()
for item in "${CORE[@]}"; do
  case $item in
    "curl,wget,git")        APT_CORE+=(curl wget git) ;;
    "build-essential")      APT_CORE+=(build-essential) ;;
    "stow")                 APT_CORE+=(stow) ;;
    "unzip,xclip")          APT_CORE+=(unzip xclip) ;;
    "fira-code,fonts-noto-color-emoji")
      APT_CORE+=(fonts-fira-code fonts-noto-color-emoji) ;;
    "fonts-symbola")
      APT_CORE+=(fonts-symbola) ;;
  esac
done
install_apt "${APT_CORE[@]}"

# --- Shell & Terminal ---
APT_SHELL=()
for item in "${SHELL_ITEMS[@]}"; do
  case $item in
    "zsh")                    APT_SHELL+=(zsh) ;;
    "tmux")                   APT_SHELL+=(tmux) ;;
    "fzf")                    APT_SHELL+=(fzf) ;;
    "fd-find,ripgrep")        APT_SHELL+=(fd-find ripgrep) ;;
    "jq")                     APT_SHELL+=(jq) ;;
    "kitty terminal")         APT_SHELL+=(kitty) ;;
    "shellcheck,shfmt")       APT_SHELL+=(shellcheck shfmt) ;;
  esac
done
install_apt "${APT_SHELL[@]}"

# --- Editors (APT) ---
APT_EDIT=()
for item in "${EDITORS[@]}"; do
  case $item in
    "neovim")  APT_EDIT+=(neovim) ;;
    "vim")     APT_EDIT+=(vim) ;;
    "helix")   APT_EDIT+=(helix) ;;
  esac
done
install_apt "${APT_EDIT[@]}"

# --- Desktop (APT) ---
APT_DESKTOP=()
for item in "${DESKTOP[@]}"; do
  case $item in
    "i3 window manager")  APT_DESKTOP+=(i3 i3blocks) ;;
    "rofi launcher")      APT_DESKTOP+=(rofi) ;;
    "waybar")             APT_DESKTOP+=(waybar) ;;
    "screenshot tools (maim, scrot, grim, slurp)")
      APT_DESKTOP+=(maim scrot grim slurp) ;;
  esac
done
install_apt "${APT_DESKTOP[@]}"

# --- Dev (APT) ---
APT_DEV=()
for item in "${DEV[@]}"; do
  case $item in
    "podman + podman-docker") APT_DEV+=(podman podman-docker) ;;
    "docker.io")               APT_DEV+=(docker.io) ;;
    "stylelint, js-beautify, tidy")  APT_DEV+=(tidy) ;;
  esac
done
install_apt "${APT_DEV[@]}"

# ── Modern CLI Tools (non-APT) ───────────────────────────────────────
install_deb() {
  local name=$1 url=$2
  command -v "$name" &>/dev/null && { ok "$name already installed"; return; }
  local tmp; tmp=$(mktemp -d); local rc=0
  curl -fsSL "$url" -o "$tmp/pkg.deb" && sudo dpkg -i "$tmp/pkg.deb" || rc=1
  if [[ $rc -ne 0 ]]; then warn "Failed: $name"; fi
  rm -rf "$tmp"
}

for item in "${SHELL_ITEMS[@]}"; do
  case $item in
    "eza (modern ls)")
      install_deb "eza" \
        "https://github.com/eza-community/eza/releases/latest/download/eza_x86_64-unknown-linux-gnu.deb"
      ;;
    "bat (modern cat)")
      install_deb "bat" \
        "https://github.com/sharkdp/bat/releases/latest/download/bat-musl_amd64.deb"
      ;;
    "starship prompt")
      if ! command -v starship &>/dev/null; then
        spinner "Installing starship..." \
          "curl -fsSL https://starship.rs/install.sh | sh -s -- -y"
      fi
      ;;
    "zoxide (smarter cd)")
      if ! command -v zoxide &>/dev/null; then
        spinner "Installing zoxide..." \
          "curl -fsSL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash"
      fi
      ;;
    "fastfetch")
      install_deb "fastfetch" \
        "https://github.com/fastfetch-cli/fastfetch/releases/latest/download/fastfetch-linux-amd64.deb"
      ;;
    "grip (markdown preview)")
      if ! command -v grip &>/dev/null; then
        pip install --user --break-system-packages grip
      fi
      ;;
    "oh-my-zsh")
      if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
        spinner "Installing Oh My Zsh..." \
          "sh -c \"\$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)\" \"\" --unattended"
      fi
      ;;
  esac
done

# --- Editors (non-APT) ---
FIREMACS_SELECTED=0
for item in "${EDITORS[@]}"; do
  case $item in
    "helix")
      if ! command -v hx &>/dev/null; then
        spinner "Installing Helix editor..." '
          tmpdir=$(mktemp -d)
          curl -fsSL https://github.com/helix-editor/helix/releases/latest/download/helix-x86_64-linux.tar.xz \
            | tar xJ -C "$tmpdir"
          sudo cp "$tmpdir"/helix-*/hx /usr/local/bin/
          sudo mkdir -p /usr/local/lib/helix
          sudo cp -r "$tmpdir"/helix-*/runtime /usr/local/lib/helix/
          rm -rf "$tmpdir"
        '
      fi
      ;;
    "zed")
      if ! command -v zed &>/dev/null; then
        spinner "Installing Zed editor..." \
          "curl -fsSL https://zed.dev/install.sh | bash"
      fi
      ;;
    "emacs (doom)")
      if ! command -v emacs &>/dev/null || [[ ! -d "$HOME/.emacs.d" ]]; then
        install_apt emacs
        if [[ ! -d "$HOME/.emacs.d" ]]; then
          spinner "Installing Doom Emacs..." \
            "git clone --depth 1 https://github.com/doomemacs/doomemacs ~/.emacs.d"
          ~/.emacs.d/bin/doom install --no-config --no-env 2>/dev/null || true
        fi
      fi
      ;;
    "emacs (firemacs)")
      if ! command -v emacs &>/dev/null; then
        install_apt emacs
      fi
      if [[ ! -d "$HOME/.emacs.d.firemacs" ]]; then
        spinner "Installing Firemacs..." \
          "git clone --depth 1 https://github.com/MarcoSantana/emacs ~/.emacs.d.firemacs"
      fi
      FIREMACS_SELECTED=1
      ;;
  esac
    done

# --- Yazi plugins ---
if command -v ya &>/dev/null; then
  spinner "Installing yazi plugins..." "ya pkg install"
fi

# --- Dev (non-APT) ---
for item in "${DEV[@]}"; do
  case $item in
    "nvm (node version manager)")
      if [[ ! -d "$HOME/.nvm" ]]; then
        spinner "Installing nvm..." \
          "curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.4/install.sh | bash"
      fi
      ;;
    "clojure tools (clj-kondo, cljfmt)")
      if ! command -v clj-kondo &>/dev/null; then
        curl -fsSL https://raw.githubusercontent.com/clj-kondo/clj-kondo/master/script/install-clj-kondo | bash -s -- --dir ~/.local/bin
      fi
      if ! command -v cljfmt &>/dev/null; then
        warn "cljfmt requires Leiningen or Clojure CLI — install manually: lein upgrade or 'clojure -Sdeps ...'"
      fi
      ;;
    "stylelint, js-beautify, tidy")
      if command -v npm &>/dev/null; then
        command -v stylelint &>/dev/null || npm install -g stylelint
        command -v js-beautify &>/dev/null || npm install -g js-beautify
      else
        warn "npm not found — install stylelint/js-beautify/tidy manually"
      fi
      ;;
    "mise (runtime version manager)")
      if ! command -v mise &>/dev/null; then
        spinner "Installing mise..." \
          "curl -fsSL https://mise.run | bash"
      fi
      ;;
  esac
done

# --- Desktop (non-APT) ---
for item in "${DESKTOP[@]}"; do
  case $item in
    "hyprland")
      if ! command -v Hyprland &>/dev/null; then
        if [[ "$ID" == ubuntu ]]; then
          sudo add-apt-repository -y ppa:hyprland/ppa
        fi
        install_apt hyprland
      fi
      ;;
    "eww widgets")
      if ! command -v eww &>/dev/null; then
        warn "eww requires Rust — install manually or via cargo: cargo install eww"
      fi
      ;;
  esac
done

# ── Stow ─────────────────────────────────────────────────────────────
header "Deploying Dotfiles"

for pkg in "${STOW_SELECTED[@]}"; do
  pkg_path="$DOTFILES/$pkg"
  if [[ -d "$pkg_path" ]]; then
    spinner "Stowing $pkg..." "cd '$DOTFILES' && stow -R '$pkg'"
    ok "  ✓ $pkg"
  else
    warn "  ✗ $pkg — directory not found"
  fi
done

# Top-level files (bashrc, bash_profile, gitconfig, vimrc, kakrc)
for f in bashrc bash_profile gitconfig vimrc kakrc; do
  if [[ -f "$DOTFILES/$f" && ! -L "$HOME/.$f" ]]; then
    run ln -sf "$DOTFILES/$f" "$HOME/.$f"
    ok "  ✓ .$f"
  fi
done

# ── Post-install tweaks ──────────────────────────────────────────────
header "Post-Install"

# Caps Lock → Ctrl (GNOME)
if command -v gsettings &>/dev/null && confirm "Map Caps Lock to Ctrl?"; then
  gsettings set org.gnome.desktop.input-sources xkb-options "['ctrl:nocaps']" 2>/dev/null && ok "  ✓ Caps Lock → Ctrl"
fi

# Firemacs daemon
if [[ "$FIREMACS_SELECTED" -eq 1 && -d "$HOME/.emacs.d.firemacs" ]]; then
  spinner "Starting Firemacs daemon..." \
    "systemctl --user daemon-reload && systemctl --user enable --now emacs-firemacs"
  ok "  ✓ Firemacs daemon"
fi

# Podman socket
if command -v podman &>/dev/null && confirm "Enable podman rootless socket?"; then
  systemctl --user enable --now podman.socket 2>/dev/null && ok "  ✓ podman socket"
fi

# Default shell → zsh
if command -v zsh &>/dev/null && [[ "$SHELL" != "$(command -v zsh)" ]] && confirm "Change default shell to zsh?"; then
  chsh -s "$(command -v zsh)" && ok "  ✓ default shell → zsh"
fi

# ── Done ─────────────────────────────────────────────────────────────
header "Done"
gum style --foreground 42 --padding "0 2" \
  "Bootstrap complete! Restart your shell: exec \$SHELL"
