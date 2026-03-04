#!/usr/bin/env bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_err() { echo -e "${RED}[ERROR]${NC} $1"; }

# 1. Preflight Checks
log_info "Starting Preflight Checks..."

# Check if running on NixOS
if [ ! -f /etc/NIXOS ]; then
    log_err "This script is designed for NixOS. Use on other systems at your own risk."
    # Exit if not on NixOS (for safety)
    exit 1
fi

# Check Disk space (require at least 5GB)
FREE_SPACE=$(df / --output=avail -h | tail -1 | tr -d 'G' | xargs)
if (( $(echo "$FREE_SPACE < 5" | bc -l) )); then
    log_warn "Low disk space detected (${FREE_SPACE}G). Cleanup is highly recommended."
fi

# 2. Cleanup & Repair (Optional/Automatic)
if [[ "$*" == *"--clean"* ]]; then
    log_info "Performing Nix Store cleanup..."
    sudo nix-collect-garbage -d
    log_info "Verifying Nix Store integrity..."
    sudo nix-store --verify --check-contents
fi

# 3. Ensure hardware config exists
log_info "Checking hardware configuration..."
if [ ! -f /etc/nixos/hardware-configuration.nix ]; then
    log_warn "Hardware configuration not found in /etc/nixos/. Generating..."
    sudo nixos-generate-config --show-hardware-config > ./nixos/nixos/hardware-configuration.nix
else
    log_info "Copying hardware configuration from /etc/nixos/..."
    cp /etc/nixos/hardware-configuration.nix ./nixos/nixos/hardware-configuration.nix
fi

# 4. Rebuild system using the flake
log_info "Building system from flake..."
if [[ "$*" == *"--macbook"* ]]; then
    sudo nixos-rebuild switch --flake .#macbook
elif [[ "$*" == *"--lenovo"* ]]; then
    sudo nixos-rebuild switch --flake .#lenovoL13
else
    sudo nixos-rebuild switch --flake .#nixos
fi

log_info "Bootstrap complete! Reboot recommended if this is a fresh install."
