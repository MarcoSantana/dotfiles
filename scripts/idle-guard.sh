#!/usr/bin/env bash
# idle-guard.sh — Skip idle actions when media is playing
# Usage: idle-guard.sh <command>
#   idle-guard.sh lock   — run lock command only if no media playing
#   idle-guard.sh dpms   — run dpms off only if no media playing
set -euo pipefail

is_playing() {
  # Returns 0 if any player is actively playing
  if ! command -v playerctl &>/dev/null; then
    return 1
  fi
  # --all-players returns empty if nothing is playing
  playerctl --all-players status 2>/dev/null | grep -q "Playing"
}

case "${1:-}" in
  lock)
    if is_playing; then
      exit 0
    fi
    pidof hyprlock || hyprlock
    ;;
  dpms)
    if is_playing; then
      exit 0
    fi
    hyprctl dispatch dpms off
    ;;
  *)
    echo "Usage: $0 {lock|dpms}"
    exit 1
    ;;
esac
