#!/usr/bin/env bash

set -e

# Colors for output
GREEN='\033[0;32m'
NC='\033[0m'

echo -e "${GREEN}Starting NixOS Bootstrap...${NC}"

# 1. Ensure hardware config exists
if [ ! -f /etc/nixos/hardware-configuration.nix ]; then
    echo "Hardware configuration not found in /etc/nixos/. Generating..."
    sudo nixos-generate-config --show-hardware-config > ./nixos/nixos/hardware-configuration.nix
else
    echo "Copying hardware configuration from /etc/nixos/..."
    cp /etc/nixos/hardware-configuration.nix ./nixos/nixos/hardware-configuration.nix
fi

# 2. Rebuild system using the flake
echo -e "${GREEN}Building system from flake...${NC}"
sudo nixos-rebuild switch --flake .#nixos

echo -e "${GREEN}Bootstrap complete! Reboot recommended if this is a fresh install.${NC}"
