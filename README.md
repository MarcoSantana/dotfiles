# Marco's Dotfiles & NixOS Configuration

This repository contains my NixOS system configuration, Home Manager settings, and various dotfiles. It is managed with **Nix Flakes** for a reproducible and streamlined experience.

## 🚀 Streamlined Installation (The Flux)

To install this configuration on a new machine:

1.  **Install NixOS**: Boot from the official ISO and perform the basic install (partitioning and mounting).
2.  **Clone this repo**:
    ```bash
    git clone https://github.com/your-username/dotfiles.git ~/dotfiles
    ```
3.  **Run the Bootstrap**:
```bash
cd ~/dotfiles
    # Recommended: Run a dry run first to verify everything evaluates correctly
    ./bootstrap.sh --dry-run
    
    # If successful, perform the real bootstrap:
./bootstrap.sh
```

### Bootstrap Flags
The `bootstrap.sh` script supports several flags for different hardware and maintenance tasks:
- `--dry-run`: Test the evaluation and build process without applying system changes.
- `--clean`: Run `nix-collect-garbage` and verify store integrity before building.
- `--macbook`: Target the MacBook Pro configuration.
- `--lenovo`: Target the Thinkpad L13 configuration.
- `--nixos` (default): Target the generic/standard NixOS configuration.

## 🛠 Maintenance

To apply changes after editing your configuration:
```bash
# Using the bootstrap script (recommended)
./bootstrap.sh

# Or using standard nixos-rebuild
sudo nixos-rebuild switch --flake .#nixos
```

## ⚠️ Common Gotchas

### 1. Picom Package Issue
The `picom` package reference in `nixos/home-manager/home.nix` is currently **commented out**. 
- **Symptom**: Evaluation error stating `picom/package.nix` does not exist.
- **Why**: An upstream issue in `nixpkgs` (release 25.11) occasionally breaks this specific path.
- **Fix**: Once `nixpkgs` is updated, you can uncomment that section in `home.nix`.

### 2. Hardware Configuration
The bootstrap script attempts to copy `/etc/nixos/hardware-configuration.nix` to the repository. 
- **Gotcha**: If you are in a non-NixOS environment (like a Live CD or another distro) or the file is missing, it will warn you.
- **Fix**: Ensure your partitions are properly mounted and `nixos-generate-config` has been run or manually provide the file.

### 3. Disk Space
Nix builds can be storage-intensive.
- **Gotcha**: If you have less than 5GB of free space, the script will warn you.
- **Fix**: Run `./bootstrap.sh --clean` or manually delete old generations with `sudo nix-collect-garbage -d`.

### 4. Flake Lock File
Always ensure your `flake.lock` is up to date if you change inputs.
```bash
nix flake update
```

### 5. EFI Mount Route mismatch
Newer NixOS versions tend to use `/boot` as the EFI mount point, while older ones used `/boot/efi`.
- **Gotcha**: The bootstrap script will stop if it detects a mismatch between your system and the config.
- **Fix**: Update `boot.loader.efi.efiSysMountPoint` in your host's `configuration.nix` to match the path detected by the bootstrap script.

### 6. Pulling Updates with Local Changes
If you have local edits but want to pull the latest version of these dotfiles:
```bash
# Save your changes temporarily
git stash
# Pull and re-apply your changes on top of the latest version
git pull --rebase
# Bring back your local edits
git stash pop
```
