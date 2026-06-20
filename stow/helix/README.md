# Gruvbox Theme for Helix

This package provides the Gruvbox theme for Helix editor.

## Installation

### Using Stow

1. Clone this repository
2. Navigate to the repository root
3. Run the setup script:

```bash
./setup.sh
```

### Manual Installation

1. Copy the `helix` directory to your home directory:

```bash
mkdir -p ~/.config/helix
mkdir -p ~/.config/helix/themes
cp dotfiles/helix/config.toml ~/.config/helix/
cp dotfiles/helix/languages.toml ~/.config/helix/
cp dotfiles/stow/helix/themes/gruvbox.toml ~/.config/helix/themes/
```

2. The Gruvbox theme will be automatically applied to Helix.

## Usage

After installation, Helix will use the Gruvbox theme by default.

## Customization

You can customize the Gruvbox theme by editing the `gruvbox.toml` file in `~/.config/helix/themes/`.

## Troubleshooting

If the theme doesn't apply correctly, check that the `gruvbox.toml` file is present in `~/.config/helix/themes/`.

## License

This theme is based on the original Gruvbox theme from the Helix project.
