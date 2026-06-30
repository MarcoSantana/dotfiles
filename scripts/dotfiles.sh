#!/usr/bin/env bash
# dotfiles — CLI entry point for managing ~/dotfiles
set -euo pipefail

DOTFILES="${DOTFILES:-$HOME/dotfiles}"
DOTFILES_DIFF_ARGS=""
DOTFILES_DIFF_FMT=""

usage() {
  echo "Usage: dotfiles <command> [args]"
  echo ""
  echo "Commands:"
  echo "  pull          git pull + update submodules"
  echo "  status        git status"
  echo "  diff [paths]  git diff (staged+unstaged) with stow-aware defaults"
  echo "  doctor        check common dotfiles issues"
  echo "  help          show this message"
  echo ""
  echo "Options for diff:"
  echo "  --cached       show staged changes only"
  echo "  --stat         show diffstat instead of full diff"
  echo ""
  echo "Examples:"
  echo "  dotfiles status"
  echo "  dotfiles diff"
  echo "  dotfiles diff hypr/ kitty/"
  echo "  dotfiles diff --stat"
  echo "  dotfiles doctor"
}

pull() {
  git -C "$DOTFILES" pull --rebase --autostash 2>/dev/null || git -C "$DOTFILES" pull
  git -C "$DOTFILES" submodule update --init --recursive 2>/dev/null || true
}

status() {
  git -C "$DOTFILES" status
}

diff_cmd() {
  local args=("$@")
  local add_args=()

  for a in "${args[@]}"; do
    case "$a" in
      --cached) add_args+=("--cached") ;;
      --stat)   DOTFILES_DIFF_ARGS="--stat" ;;
      *)        add_args+=("$a") ;;
    esac
  done

  git -C "$DOTFILES" diff $DOTFILES_DIFF_ARGS "${add_args[@]}"
}

doctor() {
  local issues=0

  echo "Checking dotfiles..."

  # Repo
  if [[ ! -d "$DOTFILES/.git" ]]; then
    echo "  ✗ No git repo at $DOTFILES"
    ((issues++))
  else
    echo "  ✓ Git repo: $DOTFILES"
  fi

  # Stow packages
  local stow_packages=()
  for d in "$DOTFILES"/*/; do
    local pkg
    pkg=$(basename "$d")
    [[ "$pkg" == scripts || "$pkg" == themes || "$pkg" == assets || "$pkg" == .githooks ]] && continue
    [[ -f "$d/.stow" || -d "$d/.config" || -d "$d/.local" || -d "$d/.themes" ]] && stow_packages+=("$pkg")
  done

  if [[ ${#stow_packages[@]} -eq 0 ]]; then
    echo "  ✗ No stow packages found"
    ((issues++))
  else
    echo "  ✓ Stow packages: ${stow_packages[*]}"
  fi

  # Home symlinks exist
  local broken=0
  for pkg in "${stow_packages[@]}"; do
    while IFS= read -r f; do
      if [[ -L "$HOME/$f" && ! -e "$HOME/$f" ]]; then
        echo "  ✗ Broken symlink: ~/$f → (missing target in $pkg)"
        ((broken++))
      fi
    done < <(stow -n -d "$DOTFILES" -t "$HOME" "$pkg" 2>&1 | grep -oP '(?<=existing target is )\S+' || true)
  done
  [[ $broken -eq 0 ]] && echo "  ✓ No broken symlinks"

  # Global gitignore / gitattributes
  if [[ -f "$HOME/.config/git/ignore" ]]; then
    echo "  ✓ Global gitignore: ~/.config/git/ignore"
  else
    echo "  ✗ Global gitignore missing"
    ((issues++))
  fi
  if [[ -f "$HOME/.config/git/attributes" ]]; then
    echo "  ✓ Global gitattributes: ~/.config/git/attributes"
  else
    echo "  ✗ Global gitattributes missing"
    ((issues++))
  fi

  # Nerd Font
  if ls "$HOME/.local/share/fonts"/FiraCodeNerdFont* &>/dev/null 2>&1; then
    echo "  ✓ FiraCode Nerd Font installed"
  else
    echo "  ✗ FiraCode Nerd Font missing"
    ((issues++))
  fi

  # Gum
  if command -v gum &>/dev/null; then
    echo "  ✓ gum installed"
  else
    echo "  ✗ gum missing"
    ((issues++))
  fi

  # Zsh as default
  if [[ "$SHELL" == *zsh ]]; then
    echo "  ✓ Default shell: zsh"
  else
    echo "  ⚠ Default shell: $SHELL (not zsh)"
  fi

  # Detect uncommitted changes in stow-managed files
  if git -C "$DOTFILES" diff --quiet 2>/dev/null; then
    echo "  ✓ Working tree clean"
  else
    local unstaged
    unstaged=$(git -C "$DOTFILES" diff --stat | tail -1)
    echo "  ⚠ Uncommitted changes: $unstaged"
    echo "    Run 'dotfiles diff' to preview, 'dotfiles status' to review"
  fi

  [[ $issues -eq 0 ]] && echo "All checks passed." || echo "$issues issue(s) found."
}

case "${1:-help}" in
  pull)   pull ;;
  status) status ;;
  diff)   shift; diff_cmd "$@" ;;
  doctor) doctor ;;
  help|--help|-h) usage ;;
  *)
    echo "Unknown: $1"
    usage
    exit 1
    ;;
esac
