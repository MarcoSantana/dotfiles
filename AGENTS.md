# AGENTS.md — Agent Context for this Repo

## Identity

Ubuntu/Debian dotfiles + bootstrap for a full Hyprland desktop with system-wide
theme switching. All configs managed via GNU Stow in `~/dotfiles`.

## Project structure

```
.
├── bootstrap.sh          # Main TUI installer (gum). Flags: --full, --minimal, --list, --dry-run
├── scripts/              # Standalone helpers (theme-switch, dotfiles CLI, emacs-daemons, etc.)
├── themes/               # 6 shell palette files sourced by theme-switch.sh
├── <pkg>/                # Stow packages — each is a GNU Stow directory
├── AGENTS.md             # This file
├── .editorconfig         # Repo-root indent rules
├── .githooks/pre-commit  # bash -n on staged .sh files
└── README.md
```

## Stow convention

Each stow package contains a `$HOME`-relative path tree. For example:

```
git/                     → stow -R git
├── .gitconfig
└── .config/git/
    ├── ignore           # Global gitignore
    └── attributes       # Global gitattributes

hypr/
├── .config/hypr/
│   ├── hyprland.conf
│   ├── hyprpaper.conf
│   ├── hyprlock.conf
│   └── hypridle.conf
└── .local/share/wayland-sessions/
    └── hyprland.desktop  # DM detection session file
```

Top-level dotfiles (`.bashrc`, `.bash_profile`, `.vimrc`, `.kakrc`) live at repo
root and are symlinked manually (not stowed), see `bootstrap.sh:614-620` for the
loop. They are not stow packages.

## Theme system

`scripts/theme-switch.sh` writes generated color files **outside stow** into
`~/.config/<app>/`. Stow owns only the template/import statements.

Files overwritten by theme-switch:

| App | File written |
|---|---|
| hyprland | `~/.config/hypr/colors.conf` (sourced by hyprland.conf) |
| waybar | `~/.config/waybar/colors.css` (imported by style.css, created if missing) |
| swaync | `~/.config/swaync/colors.css` (imported by style.css, created if missing) |
| kitty | `~/.config/kitty/current-theme.conf` (overwrites stow symlink — dirties git) |
| rofi | `~/.config/rofi/colors.rasi` (imported by config.rasi after `* {}` block) |
| GTK | `~/.local/share/themes/` (Catppuccin official release, downloaded if missing) |

Theme-switch writes **through stow symlinks** — `--dry-run` flag exists for previews.
Kitty's `current-theme.conf` is stow-managed, so switching themes dirties git.

## Palette files (`themes/*.sh`)

Each exports `TH_BG`, `TH_FG`, `TH_ACCENT`, `TH_BLACK`, `TH_RED`, `TH_GREEN`,
`TH_YELLOW`, `TH_BLUE`, `TH_MAGENTA`, `TH_CYAN`, `TH_WHITE`, `TH_BLACK_BRIGHT`,
`TH_RED_BRIGHT`, `TH_GREEN_BRIGHT`, `TH_YELLOW_BRIGHT`, `TH_BLUE_BRIGHT`,
`TH_MAGENTA_BRIGHT`, `TH_CYAN_BRIGHT`, `TH_WHITE_BRIGHT` (all hex colors).

## Key gotchas

- `gum spin` silently fails without a TTY (used in `--full` mode). Fixed via
  `spinner()` fallback: prints title + `eval "$2"` directly.
- Kitty's `current-theme.conf` is a stow symlink — theme-switch overwrites
  through it, which shows in `git status` (accepted behavior).
- `rofi/config.rasi` has `@import "colors.rasi"` after `* {}` — the import file
  must exist (created by theme-switch on first run).
- `ppa:cppiber/hyprland` (cpiber PPA) for Ubuntu 24.04 Noble. Old
  `ppa:hyprland/ppa` no longer exists.
- swaync not in any repos — installed from GitHub release
  (`ErikReider/SwayNotificationCenter`).
- swappy, nwg-look not in Pop repos — manual install or build.
- Pre-stow backup: `install-hyprland-stack.sh` backs up real files
  (`.zshrc`, `.bashrc`, etc.) before `stow -R` to avoid conflicts.
- NVIDIA env vars (`WLR_NO_HARDWARE_CURSORS`, `WLR_DRM_NO_MODIFIERS`,
  `LIBVA_DRIVER_NAME`, `GBM_BACKEND`, `__GLX_VENDOR_LIBRARY_NAME`) and
  `nvidia_drm.modeset=1` kernel param in `hyprland.conf` for GTX 1650.
- Stow "BUG" messages about `/extra/` and nix profiles are harmless (cross-fs
  symlink resolution).
- Only 3 Emacs flavors actively supported: doom, firemacs, spacemacs (centaur
  and crafted are legacy — kept for compatibility but not recommended).
- Par clon: `emacs-daemons.sh` `clone-only` action for parallel clones.
- `hypridle.conf` uses `idle-guard.sh` which checks `playerctl --all-players
  status` before DPMS/lock.

## NVIDIA

HP OMEN 15-dc1xxx — Intel UHD 630 + NVIDIA GTX 1650 Mobile (4GB, driver 590.48.01).
Kernel param `nvidia_drm.modeset=1` added via `sudo kernelstub --add-options "nvidia_drm.modeset=1"`.

## Conventions

- All scripts are `set -euo pipefail` bash.
- `DOTFILES="${DOTFILES:-$HOME/dotfiles}"` for path flexibility.
- `DRY_RUN` bool checked by all write functions.
- `FAILURES` array in bootstrap.sh tracks per-step failures, printed at end.
- `spinner()` for progress, `header()`/`subheader()`/`ok()`/`warn()`/`fail()` for TUI.

## Commands

```bash
./bootstrap.sh --full       # walk-away install (skip all prompts)
./bootstrap.sh --minimal    # core + terminal + stow
./bootstrap.sh              # interactive TUI
./bootstrap.sh --list       # show installable categories
./bootstrap.sh --dry-run    # preview without changes

theme-switch                        # gum TUI
theme-switch catppuccin mocha       # direct
theme-switch next                   # cycle
theme-switch --list                 # list themes
theme-switch --dry-run              # preview

dotfiles pull
dotfiles status
dotfiles diff [--cached] [--stat] [path]
dotfiles doctor
```
