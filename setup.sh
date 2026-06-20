#!/bin/bash

# Gruvbox Theme Setup Script for Helix
# This script sets up the Gruvbox theme for Helix using stow

set -e

echo "Setting up Gruvbox theme for Helix..."

# Create necessary directories
mkdir -p ~/.config/helix/themes

# Copy configuration files
cp dotfiles/helix/config.toml ~/.config/helix/
cp dotfiles/helix/languages.toml ~/.config/helix/
cp dotfiles/stow/helix/themes/gruvbox.toml ~/.config/helix/themes/

# Verify installation
echo ""
echo "Verifying installation..."

if [ -f ~/.config/helix/config.toml ] && grep -q "theme = \"gruvbox\"" ~/.config/helix/config.toml; then
    echo "✓ config.toml is correctly configured"
else
    echo "✗ config.toml is not correctly configured"
    exit 1
fi

if [ -f ~/.config/helix/languages.toml ]; then
    echo "✓ languages.toml is present"
else
    echo "✗ languages.toml is missing"
    exit 1
fi

if [ -f ~/.config/helix/themes/gruvbox.toml ]; then
    echo "✓ gruvbox.toml theme file is present"
else
    echo "✗ gruvbox.toml theme file is missing"
    exit 1
fi

echo ""
echo "Gruvbox theme setup completed successfully!"
echo ""
echo "Helix will now use the Gruvbox theme by default."
echo "You can restart Helix to apply the theme."
