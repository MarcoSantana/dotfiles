# Marco's Dotfiles

Dotfiles + bootstrap installer for Ubuntu/Debian → Hyprland desktop.
Manage configs with GNU Stow, cycle themes system-wide with one command.

## Quick Start

```bash
cd ~/dotfiles
./bootstrap.sh --full   # walk-away: everything, no prompts, SDDM at end
./bootstrap.sh --minimal # core + terminal + stow only
./bootstrap.sh           # interactive TUI (gum) — pick what you want
```

### On a live system (existing display manager)

```bash
./scripts/install-hyprland-stack.sh   # PPA + Hyprland stack + pre-stow backup
./bootstrap.sh --minimal              # or full, but skip the desktop section
theme-switch                          # set colors after first Hyprland login
```

### Key scripts (all in `scripts/`)

| Script | Purpose |
|---|---|
| `theme-switch.sh` | Cycle themes system-wide (gum TUI or `theme-switch catppuccin mocha`) |
| `dotfiles.sh` | CLI: `dotfiles {pull,status,diff,doctor}` — symlinked to `~/.local/bin/dotfiles` |
| `install-hyprland-stack.sh` | Desktop stack from PPA for live systems with existing DM |
| `emacs-daemons.sh` | Install/manage Emacs flavor daemons (doom/spacemacs/firemacs) |
| `emacs-manager` | Gum TUI for Emacs flavor management |
| `idle-guard.sh` | Media-aware DPMS/lock guard (used by hypridle) |
| `terminal.sh` | Consolidates terminal tool APT install |
| `zsh-fzf.sh` | ZSH + FZF setup |

## Theme System

Six themes, controlled by `theme-switch.sh`:

- **catppuccin** — mocha, macchiato
- **gruvbox** — dark, light
- **solarized** — dark, light

It writes generated color files for **hyprland**, **waybar**, **swaync**, **kitty**, and **rofi**.
First-run GTK theme download from Catppuccin GitHub releases (lazy, not in bootstrap).

```bash
theme-switch                    # gum TUI: pick family → variant
theme-switch catppuccin mocha   # direct CLI
theme-switch next               # cycle
theme-switch --list             # show all themes
theme-switch --dry-run          # preview without writing
```

## Stow Packages

```
bash/    doom/    eww/      ghostty/  hypr/    kitty/  nvim/   rofi/    vifm/
emacs/   firemacs/ git/    helix/    i3/      profile/ spacemacs/ tmux/  yazi/  zed/  zsh/
```

`dotfiles doctor` checks all stow packages, symlinks, global gitignore/attributes, font, gum, shell, and working tree.

## Desktop (Hyprland)

- Plain `.conf` (no Lua/ML4W)
- SDDM display manager (fresh install) or COSMIC greeter (live system with session file)
- Autostarts: waybar, swaync, nm-applet, blueman-applet, polkit-gnome, hyprpaper, hypridle, cliphist, eww
- NVIDIA GTX 1650 Optimus: `WLR_NO_HARDWARE_CURSORS`, `WLR_DRM_NO_MODIFIERS`, `LIBVA_DRIVER_NAME`, `GBM_BACKEND`, `__GLX_VENDOR_LIBRARY_NAME`
- Media-aware idle: checks `playerctl` before DPMS/lock

## Emacs Flavors

- **doom**: `~/.doom.d` — gleam-ts-mode + lsp-deferred
- **spacemacs**: `~/.spacemacs` — gleam layer
- **firemacs**: `~/.emacs.d.firemacs` — gleam-ts-mode + eglot-ensure

## NVIDIA Notes (HP OMEN 15-dc1xxx)

- Kernel param: `nvidia_drm.modeset=1` (added via `kernelstub`)
- Env vars in `hyprland.conf` handle the rest
- Tested with GTX 1650 Mobile — driver 590.48.01

## Maintenance

```bash
dotfiles pull        # git pull --rebase + submodules
dotfiles status      # git status
dotfiles diff [path] # diff with stow-aware defaults
dotfiles doctor      # full health check (symlinks, stow, font, gum, git configs)
```
