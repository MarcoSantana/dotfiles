# Helix Config

Personal Helix editor configuration. Stow-managed in `~/dotfiles/`.

## Structure

- `config.toml` — editor settings, keybindings
- `languages.toml` — LSP configs per language
- `themes/gruvbox.toml` — custom gruvbox dark palette theme

## Stow

Runs from `~/dotfiles/` via `stow helix`. Live config at `~/.config/helix` is a symlink to `~/dotfiles/helix/.config/helix/`.

## Keybindings (space leader)

| Binding | Action        |
|---------|---------------|
| `q`     | `:quit`       |
| `Q`     | `:quit!`      |
| `s`     | `:write`      |
| `=`     | `:format`     |
| `c`     | `:bc`         |
| `C`     | `:bca`        |
| `x`     | `:bc`         |
| `,`     | append `,`    |
| `;`     | append `;`    |
| `\ c`   | `:bc`         |
| `\ g`   | `goto_file`   |

`esc` collapses selections, keeps primary, then writes (`:w`).

## LSP servers

| Language                 | Server(s)                                                    |
|--------------------------|--------------------------------------------------------------|
| Typst                    | `tinymist`                                                   |
| Vue                      | `vue-language-server` + `typescript-language-server`         |
| JavaScript / TypeScript  | `typescript-language-server`                                 |
| Clojure / ClojureScript  | `clojure-lsp`                                                |
| SQL (PostgreSQL)         | `postgres-language-server` (via `lsp-proxy`)                 |

Vue TS SDK pinned to `/home/msantana/.nvm/versions/node/v24.14.0/lib/node_modules/typescript/lib`.

## Notable settings

- relative line numbers, true-color, undercurl, color-modes, cursorline
- auto-save on focus loss, auto-completion, no idle timeout
- gutter order: `diagnostics, spacer, diff, line-numbers, spacer, spacer`
- tree-sitter indent heuristic
- tab → `→`, newline always shown, spaces hidden
- soft-wrap enabled
- inlay hints currently off (commented out)
