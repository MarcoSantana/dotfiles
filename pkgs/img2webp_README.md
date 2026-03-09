# Image to WebP Conversion Utility

This utility provides a recursive image-to-WebP conversion script (`img2webp`) that automatically organizes output into a sibling directory, making it ideal for batch processing image sets while preserving the original folder structure.

## Features
-   **Recursive Search:** Automatically finds images in all subdirectories.
-   **Case-Insensitive:** Handles `.jpg`, `.JPG`, `.png`, `.PNG`, etc.
-   **Incremental Logic:** Skips files that have already been converted unless the source image is newer.
-   **Structured Output:** Creates a sibling directory `[origin_dir]_webp_converted` to avoid cluttering your source files.
-   **NixOS Optimized:** Designed to be managed as a first-class citizen in your dotfiles.

---

## 1. Quick Usage (Standalone)
If you have `imagemagick` installed, you can run the script directly from this directory:

```bash
chmod +x img2webp.sh
./img2webp.sh
```

## 2. Global Integration (NixOS / Home Manager)
To make `img2webp` available everywhere and preserve it in your dotfiles:

### Step A: Move the Nix Package
Move the provided `img2webp.nix` into your dotfiles repository:
```bash
mkdir -p ~/dotfiles/pkgs
cp img2webp.nix ~/dotfiles/pkgs/
```

### Step B: Register the Package
Open your Home Manager configuration (typically `~/dotfiles/nixos/home-manager/home.nix`) and add it to your `home.packages`:

```nix
{ pkgs, ... }: {
  home.packages = [
    # ... your other packages ...
    (pkgs.callPackage ../../pkgs/img2webp.nix {})
  ];
}
```

### Step C: Apply Configuration
Rebuild your system/home configuration as usual:
```bash
sudo nixos-rebuild switch --flake ~/dotfiles#nixos
```

---

## Usage Command
Once installed, simply navigate to any directory containing images and run:
```bash
img2webp
```
The script will calculate the parent folder name and create the corresponding `_webp_converted` directory automatically.

## Requirements (automatically handled by Nix)
-   `bash`
-   `imagemagick` (provides `magick` command)
-   `findutils` (provides `find`)
