#!/bin/bash
# Tailwind CSS Language Server wrapper — ensures the right node is used
LOG="$HOME/.local/share/tailwind-lsp-wrapper.log"
NODE="$(which node 2>/dev/null || echo "/usr/bin/node")"
LS="$(which tailwindcss-language-server 2>/dev/null || echo "$(dirname "$NODE")/tailwindcss-language-server")"

echo "Tailwind LSP started at $(date)" >> "$LOG"
echo "Args: $*" >> "$LOG"
echo "Node: $($NODE -v)" >> "$LOG"
exec "$NODE" "$LS" "$@" 2>> "$LOG"
