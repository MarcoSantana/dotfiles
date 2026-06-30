#!/usr/bin/env bash
# zsh-fzf.sh — ZSH + FZF configuration
set -euo pipefail

HAS()  { command -v "$1" &>/dev/null; }
INFO() { echo -e "\\033[1;34m➜\\033[0m" "$@"; }
OK()   { echo -e "\\033[1;32m✓\\033[0m" "$@"; }
SKIP() { echo -e "\\033[1;33m–\\033[0m" "$@"; }

append_if_missing() {
  local file="$1" text="$2"
  grep -qsxF "$text" "$file" 2>/dev/null || echo "$text" >> "$file"
}

detect_distro() {
  if [[ -f /etc/os-release ]]; then
    . /etc/os-release
    DISTRO="$ID"
    case "$DISTRO" in
      ubuntu|debian|pop|linuxmint) PKG_MGR="apt" ;;
      fedora|rhel|centos)           PKG_MGR="dnf" ;;
      *)                            PKG_MGR="apt" ;;
    esac
  fi
}

install_pkg() {
  case "$PKG_MGR" in
    apt) sudo apt install -y "$@" ;;
    dnf) sudo dnf install -y "$@" ;;
  esac
}

ZSHRC="${ZSH:-$HOME/.zshrc}"

detect_distro
install_pkg fzf fd-find ripgrep zoxide

mkdir -p "$HOME/.local/bin"

# Binary symlinks
HAS fdfind && ! HAS fd && ln -sf "$(which fdfind)" "$HOME/.local/bin/fd" 2>/dev/null || true

append_if_missing "$ZSHRC" 'export PATH="$HOME/.local/bin:$PATH"'

# ── zoxide ────────────────────────────────────────────────────
if ! HAS zoxide; then
  curl -fsSL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash
fi
append_if_missing "$ZSHRC" 'eval "$(zoxide init zsh)"'

# ── FZF core ──────────────────────────────────────────────────
append_if_missing "$ZSHRC" 'export FZF_DEFAULT_COMMAND="fd --type f --hidden --exclude .git"'
append_if_missing "$ZSHRC" 'export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"'
append_if_missing "$ZSHRC" 'export FZF_ALT_C_COMMAND="fd --type d --hidden --exclude .git"'
append_if_missing "$ZSHRC" \
  'export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --border --preview \"bat --color=always {} 2>/dev/null || tree -C {} | head -200\""'

# ── ZSH keybindings ───────────────────────────────────────────
append_if_missing "$ZSHRC" '
# ---- FZF custom keybindings ----

# Ctrl+P → files (like VSCode)
fzf-file-widget() {
  local file
  file=$(fd . | fzf --preview "bat --color=always {}")
  LBUFFER="${LBUFFER}${file}"
}
zle -N fzf-file-widget
bindkey "^P" fzf-file-widget

# Ctrl+G → live grep
fzf-grep-widget() {
  local selected
  selected=$(rg --line-number --no-heading --color=always "" | \
    fzf --ansi --delimiter : \
    --preview "bat --color=always {1} --highlight-line {2}")
  if [ -n "$selected" ]; then
    local file=$(echo "$selected" | cut -d: -f1)
    local line=$(echo "$selected" | cut -d: -f2)
    LBUFFER="nvim +$line $file"
  fi
}
zle -N fzf-grep-widget
bindkey "^G" fzf-grep-widget

# Alt+C → smart cd (zoxide + fzf)
fzf-cd-widget() {
  local dir
  dir=$(zoxide query -l | fzf)
  if [ -n "$dir" ]; then
    cd "$dir"
    zle reset-prompt
  fi
}
zle -N fzf-cd-widget
bindkey "^[c" fzf-cd-widget
'

# ── Spotlight launcher (Ctrl+Space) ───────────────────────────
append_if_missing "$ZSHRC" '
flaunch() {
  local cmd
  cmd=$(printf "Files\nGrep\nProjects\nGit\n" | fzf --prompt="⚡ ")
  case "$cmd" in
    Files)
      fd . | fzf --preview "bat --color=always {}" | xargs -r nvim
      ;;
    Grep)
      rg --line-number "" | fzf --delimiter : \
        --preview "bat --color=always {1} --highlight-line {2}"
      ;;
    Projects)
      zoxide query -l | fzf | xargs -r cd
      ;;
    Git)
      git status
      ;;
  esac
}
zle -N flaunch
bindkey "^ " flaunch
'

# ── Aliases ───────────────────────────────────────────────────
append_if_missing "$ZSHRC" 'alias ls="eza --icons --group-directories-first"'
append_if_missing "$ZSHRC" 'alias ll="eza -lah --icons --git"'
append_if_missing "$ZSHRC" 'alias cat="bat"'

OK "ZSH + FZF setup complete."
