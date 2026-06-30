#!/usr/bin/env bash
#
# bootstrap.sh — Interactive Ubuntu/Debian dotfiles installer
# Uses gum for a pretty TUI. You choose what goes in.
#
set -euo pipefail

DOTFILES="$HOME/dotfiles"
DRY_RUN=false
FULL=false
MINIMAL=false
START=$SECONDS

# ── Parse args ───────────────────────────────────────────────────────
while [[ $# -gt 0 ]]; do
  case $1 in
    --full)    FULL=true ;;
    --minimal) FULL=true; MINIMAL=true ;;
    --list|-l)
      echo "Available categories (use with --full or manual TUI selection):"
      echo ""
      echo "  TERMINAL:  gui tools, zsh-fzf, tmux plugins, oh-my-zsh"
      echo "  EDITORS:   helix, zed, emacs (doom/firemacs/spacemacs)"
      echo "  DEV:       nvm, clojure tools, language servers (clojure-lsp,"
      echo "             tinymist, luau-lsp), npm globals (vue-language-server,"
      echo "             pi-agent, typescript-language-server), mise"
      echo "  DESKTOP:   hyprland (full stack: sddm, swaync, pipewire,"
      echo "             nm-applet, blueman, cups, xdg-desktop-portal-hyprland,"
      echo "             grim+slurp+swappy, wl-clipboard+cliphist, wdisplays,"
      echo "             nwg-look, qt5ct/6ct, brightnessctl, playerctl, upower,"
      echo "             thunar+gvfs, fonts-font-awesome, polkit-gnome),"
      echo "             eww widgets"
      echo "  THEMING:   stow (symlinks all dotfiles), nerd font"
      exit 0 ;;
    --dry-run) DRY_RUN=true ;;
    --help|-h)
      echo "Usage: $0 [--full|--minimal|--dry-run|--list]"
      echo "  --full     Install everything, no prompts (walk away)"
      echo "  --minimal  Core + terminal tools + stow only"
      echo "  --dry-run  Show what would be done"
      echo "  --list     Show installable categories"
      exit 0 ;;
    *) echo "Unknown: $1"; exit 1 ;;
  esac; shift
done

FAILURES=()

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
step()      { gum style --foreground 33 "[$1/$2]${3:+ $3}"; }

# ── Auto-selection for --full / --minimal ────────────────────────────
if $FULL; then
  choose() { printf '%s\n' "${@:2}"; }
  confirm() { return 0; }
  prompt()  { echo "${2:-}"; }
fi

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
if ! $MINIMAL; then
  subheader "Editors"
  EDITORS=$(choose "Pick your weapons" \
    "neovim" \
    "helix" \
    "zed" \
    "emacs (centaur)" \
    "emacs (crafted)" \
    "emacs (doom)" \
    "emacs (firemacs)" \
    "emacs (spacemacs)" \
    "vim")
  # --full: only install the flavors worth keeping
  if $FULL; then
    EDITORS=$(printf '%s\n' "emacs (doom)" "emacs (firemacs)" "emacs (spacemacs)")
  fi
fi

# --- Category: Desktop / WM ---
if ! $MINIMAL; then
  subheader "Desktop / Window Manager"
  DESKTOP=$(choose "Desktop components" \
    "i3 window manager" \
    "rofi launcher" \
    "eww widgets" \
    "waybar" \
    "hyprland" \
    "screenshot tools (maim, scrot, grim, slurp)")
  # --full: drop i3, use hyprland instead
  if $FULL; then
    DESKTOP=$(printf '%s\n' "${DESKTOP[@]}" | grep -v "i3 window manager")
  fi
fi

# --- Category: Development ---
if ! $MINIMAL; then
  subheader "Development"
  DEV=$(choose "Dev tooling" \
    "nvm (node version manager)" \
    "mise (runtime version manager)" \
    "podman + podman-docker" \
    "docker.io" \
    "clojure tools (clj-kondo, cljfmt)" \
    "stylelint, js-beautify, tidy" \
    "language servers (clojure-lsp, tinymist, luau)" \
    "npm globals (vue-language-server, pi-agent, typescript-language-server)")
fi

# --- Category: Dotfiles (Stow) ---
header "Dotfiles (Stow packages)"

AVAILABLE_STOW=()
for d in "$DOTFILES"/*/; do
  name=$(basename "$d")
  [[ "$name" == .git || "$name" == nixos || "$name" == assets || "$name" == scripts ]] && continue
  AVAILABLE_STOW+=("$name")
done

STOW_SELECTED=()
if $FULL; then
  STOW_SELECTED=("${AVAILABLE_STOW[@]}")
else
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
fi

if [[ ${#STOW_SELECTED[@]} -eq 0 ]]; then
  warn "No stow packages selected — skipping dotfiles deployment."
fi

# ── Confirmation ─────────────────────────────────────────────────────
if $FULL; then
  gum style --foreground 42 "⏩ Full install — proceeding..."
else
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
fi

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

TOTAL_STEPS=8

# Update once
export DEBIAN_FRONTEND=noninteractive
spinner "Updating package lists..." "sudo apt-get update -qq"

# --- Core ---
step 1 "$TOTAL_STEPS" "System packages"
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
HYPRLAND_SELECTED=false
for item in "${DESKTOP[@]}"; do
  case $item in
    "i3 window manager")
      warn "i3 is deprecated — use hyprland instead"
      APT_DESKTOP+=(i3 i3blocks) ;;
    "rofi launcher")      APT_DESKTOP+=(rofi) ;;
    "eww widgets")        APT_DESKTOP+=(libgtk-3-dev) ;;
    "waybar")             APT_DESKTOP+=(waybar) ;;
    "hyprland")
      HYPRLAND_SELECTED=true
      APT_DESKTOP+=(
        hyprland hyprpaper hyprlock hypridle
        sddm swaync
        pipewire pipewire-pulse pipewire-audio wireplumber pavucontrol
        network-manager-gnome blueman
        cups system-config-printer
        xdg-desktop-portal-hyprland xdg-desktop-portal-gtk
        grim slurp swappy wl-clipboard
        wdisplays wlr-randr nwg-look
        qt5ct qt6ct
        brightnessctl playerctl
        upower power-profiles-daemon
        thunar gvfs thunar-volman udisks2
        fonts-font-awesome
        policykit-1-gnome
      ) ;;
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
step 2 "$TOTAL_STEPS" "Shell tools"
install_deb() {
  local name=$1 url=$2
  command -v "$name" &>/dev/null && { ok "$name already installed"; return 0; }
  local tmp; tmp=$(mktemp -d)
  if curl -fsSL "$url" -o "$tmp/pkg.deb" && sudo dpkg -i "$tmp/pkg.deb"; then
    ok "$name installed"; local rc=0
  else
    warn "Failed: $name"; local rc=1
  fi
  rm -rf "$tmp"
  return $rc
}

for item in "${SHELL_ITEMS[@]}"; do
  case $item in
    "eza (modern ls)")
      install_deb "eza" \
        "https://github.com/eza-community/eza/releases/latest/download/eza_x86_64-unknown-linux-gnu.deb" \
        || FAILURES+=("eza")
      ;;
    "bat (modern cat)")
      install_deb "bat" \
        "https://github.com/sharkdp/bat/releases/latest/download/bat-musl_amd64.deb" \
        || FAILURES+=("bat")
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
        "https://github.com/fastfetch-cli/fastfetch/releases/latest/download/fastfetch-linux-amd64.deb" \
        || FAILURES+=("fastfetch")
      ;;
    "grip (markdown preview)")
      if ! command -v grip &>/dev/null; then
        pip install --user --break-system-packages grip || FAILURES+=("grip")
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
step 3 "$TOTAL_STEPS" "Editors"
EMACS_SELECTED=()
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
    "emacs (centaur)")
      EMACS_SELECTED+=("centaur")
      ;;
    "emacs (crafted)")
      EMACS_SELECTED+=("crafted")
      ;;
    "emacs (doom)")
      EMACS_SELECTED+=("doom")
      ;;
    "emacs (firemacs)")
      EMACS_SELECTED+=("firemacs")
      ;;
    "emacs (spacemacs)")
      EMACS_SELECTED+=("spacemacs")
      ;;
  esac
done

if [[ ${#EMACS_SELECTED[@]} -gt 0 ]]; then
  if ! command -v emacs &>/dev/null; then
    install_apt emacs
  fi
  # Parallel clones
  pids=()
  for flavor in "${EMACS_SELECTED[@]}"; do
    ("$DOTFILES/scripts/emacs-daemons.sh" clone-only "$flavor") & pids+=($!)
  done
  wait "${pids[@]}" || true
  # Then create services + start daemons (sequential, fast)
  "$DOTFILES/scripts/emacs-daemons.sh" "${EMACS_SELECTED[@]}"
fi

# --- Yazi plugins ---
if command -v ya &>/dev/null; then
  spinner "Installing yazi plugins..." "ya pkg install"
fi

# --- Dev (non-APT) ---
step 4 "$TOTAL_STEPS" "Dev tooling & language servers"
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
        warn "npm not found — install stylelint/js-beautify manually"
      fi
      ;;
    "language servers (clojure-lsp, tinymist, luau)")
      # clojure-lsp — binary install
      if ! command -v clojure-lsp &>/dev/null; then
        spinner "Installing clojure-lsp..." \
          "curl -fsSL https://github.com/clojure-lsp/clojure-lsp/releases/latest/download/clojure-lsp-native-linux-amd64.zip -o /tmp/clojure-lsp.zip && unzip -o /tmp/clojure-lsp.zip -d /tmp && sudo mv /tmp/clojure-lsp /usr/local/bin/ && rm -f /tmp/clojure-lsp.zip" \
          || FAILURES+=("clojure-lsp")
      fi
      # tinymist (Typst LSP) — cargo or prebuilt
      if ! command -v tinymist &>/dev/null; then
        if command -v cargo &>/dev/null; then
          cargo install tinymist || FAILURES+=("tinymist")
        else
          warn "tinymist requires Rust — install via: cargo install tinymist"
        fi
      fi
      # luau-lsp
      if ! command -v luau-lsp &>/dev/null; then
        spinner "Installing luau-lsp..." \
          "curl -fsSL https://github.com/luau-lang/luau/releases/latest/download/luau-ubuntu-x86_64.zip -o /tmp/luau.zip && unzip -o /tmp/luau.zip -d /tmp && sudo mv /tmp/luau-lsp /usr/local/bin/ && rm -f /tmp/luau.zip" \
          || FAILURES+=("luau-lsp")
      fi
      ;;
    "npm globals (vue-language-server, pi-agent, typescript-language-server)")
      if command -v npm &>/dev/null; then
        # Load nvm if available for correct node version
        export NVM_DIR="$HOME/.nvm"
        [[ -s "$NVM_DIR/nvm.sh" ]] && source "$NVM_DIR/nvm.sh" || true
        command -v vue-language-server &>/dev/null || \
          spinner "Installing @vue/language-server..." \
            "npm install -g @vue/language-server" || FAILURES+=("vue-language-server")
        command -v typescript-language-server &>/dev/null || \
          spinner "Installing typescript-language-server..." \
            "npm install -g typescript-language-server" || FAILURES+=("typescript-language-server")
        command -v pi &>/dev/null || \
          spinner "Installing Pi AI coding agent..." \
            "npm install -g @earendil-works/pi-coding-agent" || FAILURES+=("pi-agent")
      else
        warn "npm not found — install npm globals manually"
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
step 5 "$TOTAL_STEPS" "Desktop / WM"
for item in "${DESKTOP[@]}"; do
  case $item in
    "hyprland")
      if ! command -v Hyprland &>/dev/null; then
        if [[ "$ID" == ubuntu ]]; then
          spinner "Adding Hyprland PPA..." \
            "sudo add-apt-repository -y ppa:hyprland/ppa && sudo apt-get update -qq"
        fi
      fi
      ;;
    "eww widgets")
      if ! command -v eww &>/dev/null; then
        warn "eww requires Rust — install manually or via cargo: cargo install eww"
      fi
      ;;
  esac
done

# Post-APT Hyprland setup: enable services
if $HYPRLAND_SELECTED; then
  # sddm as default display manager
  if ! systemctl is-enabled sddm &>/dev/null; then
    sudo systemctl enable sddm 2>/dev/null && ok "  ✓ sddm enabled"
  fi
  # User-level services
  systemctl --user enable --now pipewire pipewire-pulse wireplumber 2>/dev/null || true
  # Bluetooth
  if ! systemctl is-enabled bluetooth &>/dev/null; then
    sudo systemctl enable bluetooth 2>/dev/null && ok "  ✓ bluetooth enabled"
  fi
  # Printers
  if ! systemctl is-enabled cups &>/dev/null; then
    sudo systemctl enable cups 2>/dev/null && ok "  ✓ cups enabled"
  fi
  # Power profiles
  if ! systemctl is-enabled power-profiles-daemon &>/dev/null; then
    sudo systemctl enable --now power-profiles-daemon 2>/dev/null || true
  fi
  # Start sddm now (only if not already running a display server)
  if ! systemctl is-active sddm &>/dev/null; then
    sudo systemctl start sddm 2>/dev/null || true
  fi
  ok "  ✓ Hyprland desktop stack ready"
fi

# ── Stow ─────────────────────────────────────────────────────────────
step 6 "$TOTAL_STEPS" "Dotfiles (stow)"
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

# Top-level files (bashrc, bash_profile, vimrc, kakrc)
for f in bashrc bash_profile vimrc kakrc; do
  if [[ -f "$DOTFILES/$f" && ! -L "$HOME/.$f" ]]; then
    run ln -sf "$DOTFILES/$f" "$HOME/.$f"
    ok "  ✓ .$f"
  fi
done

# ── Post-install tweaks ──────────────────────────────────────────────
step 7 "$TOTAL_STEPS" "Post-install"
header "Post-Install"

# Caps Lock → Ctrl (GNOME)
if command -v gsettings &>/dev/null && confirm "Map Caps Lock to Ctrl?"; then
  gsettings set org.gnome.desktop.input-sources xkb-options "['ctrl:nocaps']" 2>/dev/null && ok "  ✓ Caps Lock → Ctrl"
fi

# Restart emacs daemons after stow (stow may replace service files)
for flavor in "${EMACS_SELECTED[@]}"; do
  svc="emacs-${flavor}"
  if systemctl --user is-enabled "$svc" &>/dev/null; then
    systemctl --user daemon-reload 2>/dev/null
    systemctl --user restart "$svc" 2>/dev/null && ok "  ✓ $svc restarted" || true
  fi
done

# Nerd Font (--full only)
if $FULL; then
  step 7 "$TOTAL_STEPS" "Nerd Font"
  FONT_DIR="$HOME/.local/share/fonts"
  mkdir -p "$FONT_DIR"
  if ls "$FONT_DIR"/FiraCodeNerdFont* &>/dev/null 2>&1; then
    ok "  ✓ FiraCode Nerd Font already installed"
  else
    spinner "Installing FiraCode Nerd Font..." \
      "curl -fsSL https://github.com/ryanoasis/nerd-fonts/releases/latest/download/FiraCode.tar.xz \
        | tar xJ -C '$FONT_DIR' 2>/dev/null && fc-cache -f '$FONT_DIR'"
    ok "  ✓ FiraCode Nerd Font"
  fi
fi

# Podman socket
if command -v podman &>/dev/null && confirm "Enable podman rootless socket?"; then
  systemctl --user enable --now podman.socket 2>/dev/null && ok "  ✓ podman socket"
fi

# Default shell → zsh
if command -v zsh &>/dev/null && [[ "$SHELL" != "$(command -v zsh)" ]] && confirm "Change default shell to zsh?"; then
  chsh -s "$(command -v zsh)" && ok "  ✓ default shell → zsh"
fi

# Git hooks
if [[ -d "$DOTFILES/.githooks" ]]; then
  git config core.hooksPath "$DOTFILES/.githooks" 2>/dev/null && ok "  ✓ git hooks configured"
fi

# dotfiles CLI
mkdir -p "$HOME/.local/bin"
if [[ ! -L "$HOME/.local/bin/dotfiles" ]]; then
  ln -sf "$DOTFILES/scripts/dotfiles.sh" "$HOME/.local/bin/dotfiles" && ok "  ✓ dotfiles CLI → ~/.local/bin/dotfiles"
fi

# ── Done ─────────────────────────────────────────────────────────────
DURATION=$((SECONDS - START))
header "Done"
if $FULL; then
  gum style --border double --padding "1 2" \
    "Bootstrap complete in ${DURATION}s"
  if [[ ${#FAILURES[@]} -gt 0 ]]; then
    gum style --foreground 220 "Completed with ${#FAILURES[@]} failure(s):"
    for f in "${FAILURES[@]}"; do
      gum style --foreground 196 "  ✗ $f"
    done
    echo
    gum style --foreground 220 "Re-run individual installers: ~/dotfiles/scripts/*.sh"
  else
    gum style --foreground 42 "All steps completed successfully."
  fi
else
  gum style --foreground 42 --padding "0 2" \
    "Bootstrap complete! Restart your shell: exec \$SHELL"
fi
