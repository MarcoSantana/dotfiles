# Marco's Dotfiles & NixOS Configuration

This repository contains my NixOS system configuration, Home Manager settings, and various dotfiles.

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
    ./bootstrap.sh
    ```

The bootstrap script will:
- Detect your hardware and generate a `hardware-configuration.nix`.
- Rebuild the system using the unified **Nix Flake**.
- Apply all system services (EXWM, Syncthing, etc.) and user settings (AstroVim, Emacs 30).

## 🛠 Maintenance

To apply changes after editing your configuration:
```bash
sudo nixos-rebuild switch --flake .#nixos
```
