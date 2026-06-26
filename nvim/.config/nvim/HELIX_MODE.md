# Helix Mode — Onboarding for Next Agent

## What Was Done

Two groups of changes to the LazyVim Neovim config at `~/.config/nvim/` (symlinked via stow to `~/dotfiles/nvim/.config/nvim/`):

### 1. Soft Diagnostics

**Goal**: Reduce visual noise from LSP squiggly underlines. Replace harsh `undercurl` with flat `underline`, disable inline virtual text, add gentle cycling.

**Files**:

| File | Change |
|------|--------|
| `lua/config/autocmds.lua` | ColorScheme autocmd that overrides `DiagnosticUnderline{Error,Warn,Info,Hint}` — strips `undercurl`, sets `underline`. Theme-agnostic (preserves theme colors). |
| `lua/config/options.lua` | Sets `vim.diagnostic.config({ virtual_text = false, signs = true, underline = true, update_in_insert = false, severity_sort = true })` |
| `lua/config/keymaps.lua` | `<leader>td` cycles: All → Warn+ → Errors → Off (tracked via `vim.g.diag_level`). `<leader>tD` toggles virtual text independently. |

### 2. Helix Mode Toggle

**Goal**: Override Neovim keybindings with Helix-style ones via a runtime toggle. Adds ⚡ icon to lualine when active.

**Files**:

| File | Change |
|------|--------|
| `lua/plugins/helix.lua` | Single file containing toggle function, Helix key overrides, and lualine ⚡ component. |

**Architecture**:

```
helix.lua
├── top-level: init helix_maps table, vim.g.helix_mode flag
├── apply_helix()     — sets all Helix keymaps, tracks in helix_maps[]
├── remove_helix()    — iterates helix_maps[], pcall(vim.keymap.del)
├── _G.toggle_helix_mode() — global function, flips flag, calls apply/remove, notifies
├── <leader>th keymap — toggle binding
└── return { lualine spec → ⚡ cond = vim.g.helix_mode }
```

**Key insight**: `apply_helix` and `remove_helix` are `local` functions defined BEFORE `_G.toggle_helix_mode` (Lua hoisting fix applied — commit `ff5a447`).

**Overrides applied when ON**:

| Key | Behavior | Original |
|-----|----------|----------|
| `x` | select whole line (`V`) | delete char |
| `X` | shrink selection up one line | delete char backward |
| `C` | duplicate line down (`yyp`) | change to end of line |
| `A-C` | duplicate line up | — |
| `A-o` | expand selection (treesitter parent) | — |
| `A-i` | shrink selection (treesitter child) | — |
| `A-n` | next sibling (`]m`) | — |
| `A-p` | prev sibling (`[m`) | — |
| `A-k` | next diagnostic | — |
| `A-j` | prev diagnostic | — |

**Turning OFF** deletes all tracked maps via `vim.keymap.del`. Default Neovim behavior returns automatically.

## Toggle Reference

| Binding | Action |
|---------|--------|
| `<Space>th` | Toggle Helix mode ON/OFF |
| `<Space>td` | Cycle diagnostic level (All→Warn+→Errors→Off) |
| `<Space>tD` | Toggle virtual text |
| `<Space>ts` | Toggle spell check |
| `<Space>tl` | Cycle spell language (es/en) |
| `<Space>tc` | Toggle Typst text/code mode |
| `<Space>bg` | Toggle light/dark theme |

## Dotfiles / Git

- `~/.config/nvim` is a **symlink** → `~/dotfiles/nvim/.config/nvim/` (managed by `stow nvim` from `~/dotfiles/`)
- Git remote: `https://github.com/MarcoSantana/dotfiles.git`
- Last commit: `ff5a447` fix(helix): hoist apply_helix/remove_helix before toggle_helix_mode

## To Verify

- Restart Neovim, press `<Space>th` — should toggle ON with ⚡ in statusline
- Press `<Space>td` — cycles through diag levels with notification
- `x` deletes normally when OFF, selects line when ON
- `C` changes to end of line when OFF, duplicates line when ON
- ⚡ icon only shows when Helix mode is active

## Pre-existing Config Notes

- LazyVim, `gruvbox` as primary colorscheme (also has catppuccin configured)
- Leader key is `<Space>` (LazyVim default)
- `flash.nvim` on `s`/`S` for Helix-style jump (in `editor.lua`)
- Emacs-style insert mode mappings (`C-f`, `C-b`, `C-a`, `C-k`, `C-y`, `M-b`, `M-f`, etc.)
- Set of LSP servers: typst (tinymist), vue, typescript, clojure-lsp, postgres
- Spell language cycles `es`/`en`
