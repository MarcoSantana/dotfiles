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

# Initialize variables
DRY_RUN=false
CLEAN=false
HOST="nixos"

# Parse arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --dry-run) DRY_RUN=true ;;
        --clean) CLEAN=true ;;
        --macbook) HOST="macbook" ;;
        --lenovo) HOST="lenovoL13" ;;
        *) log_warn "Unknown argument: $1" ;;
    esac
    shift
done

# 1. Preflight Checks
log_info "Starting Preflight Checks..."

# Check if running on NixOS
ON_NIXOS=false
if [ -f /etc/NIXOS ]; then
    ON_NIXOS=true
fi

if [ "$ON_NIXOS" = false ] && [ "$DRY_RUN" = false ]; then
    log_err "This script is designed for NixOS. Use on other systems at your own risk."
    exit 1
fi

# Check Disk space (require at least 5GB)
if command -v df >/dev/null 2>&1; then
    FREE_SPACE=$(df / --output=avail -k | tail -1 | xargs)
    # 5GB = 5242880 KB
    if [ "$FREE_SPACE" -lt 5242880 ]; then
        log_warn "Low disk space detected (less than 5GB). Cleanup is highly recommended."
    fi
fi

# 2. Cleanup & Repair
if [ "$CLEAN" = true ]; then
    log_info "Performing Nix Store cleanup..."
    if [ "$DRY_RUN" = true ]; then
        log_info "[DRY-RUN] sudo nix-collect-garbage -d"
    else
        sudo nix-collect-garbage -d
    fi
    
    log_info "Verifying Nix Store integrity..."
    if [ "$DRY_RUN" = true ]; then
        log_info "[DRY-RUN] sudo nix-store --verify --check-contents"
    else
        sudo nix-store --verify --check-contents
    fi
fi

# 3. Handle Host-Specific Logic
log_info "Target Host: $HOST"

# 4. Ensure hardware config exists for the target host
HW_PATH="./nixos/$HOST/hardware-configuration.nix"
log_info "Checking hardware configuration for $HOST..."

if [ ! -f /etc/nixos/hardware-configuration.nix ]; then
    log_warn "Hardware configuration not found in /etc/nixos/."
    if [ "$DRY_RUN" = false ]; then
        log_info "Generating..."
        sudo nixos-generate-config --show-hardware-config > "$HW_PATH"
    fi
else
    log_info "Copying hardware configuration from /etc/nixos/ to $HW_PATH..."
    if [ "$DRY_RUN" = true ]; then
        log_info "[DRY-RUN] cp /etc/nixos/hardware-configuration.nix $HW_PATH"
    else
        cp /etc/nixos/hardware-configuration.nix "$HW_PATH"
    fi
fi

# 5. Rebuild system using the flake
log_info "Building system from flake for $HOST..."

if [ "$DRY_RUN" = true ]; then
    log_info "Running dry-run build..."
    nix build ".#nixosConfigurations.$HOST.config.system.build.toplevel" --dry-run --show-trace --verbose
else
    sudo nixos-rebuild switch --flake ".#$HOST"
fi

log_info "Bootstrap process completed!"
if [ "$DRY_RUN" = false ]; then
    log_info "Reboot recommended if this is a fresh install."
fi
