# 🚀 Neovim Migration & AI Cheatsheet

This document outlines the custom keybindings and AI integrations added during your migration from AstroNvim to LazyVim.

## 🤖 AI Integrations (The "Cursor" Experience)

| Keybind | Action | Description |
| :--- | :--- | :--- |
| **`<A-f>`** | **Accept Suggestion** | (Alt+f) Accept NeoCodeium ghost-text autocomplete. |
| **`<leader>aa`** | **Avante Chat** | Open the Cursor-like sidebar for AI chat/reasoning. |
| **`<leader>ae`** | **Avante Edit** | Edit selected code or the current line with AI. |
| **`<leader>a?`** | **Switch Provider** | Toggle between **Gemini**, **Ollama**, and **LM Studio**. |
| **`<leader>Ai`** | **Aider Toggle** | Open/Toggle the Aider terminal (Gemini 1.5 Pro). |
| **`<leader>As`** | **Aider Send** | Send current selection or line to Aider. |
| **`<leader>Aa`** | **Aider Add File** | Add the current file to the Aider session. |

---

## ✍️ Modern Editing & Ergonomics

| Keybind | Action | Example / Usage |
| :--- | :--- | :--- |
| **`<leader>nj`** | **Logseq Journal**| Open your Logseq Daily Journal entry. |
| **`<leader>ns`** | **Logseq Search** | Search for filenames in your Logseq graph. |
| **`<leader>ng`** | **Logseq Grep**   | Search for text content in your Logseq graph. |
| **`ys`** | **Add Surround** | `ysiw"` → surround inner word with `"` |
| **`ds`** | **Delete Surround** | `ds"` → remove surrounding `"` |
| **`cs`** | **Change Surround** | `cs"'` → change surrounding `"` to `'` |
| **`s`** | **Flash Jump** | Type `s` + two characters to jump anywhere on screen. |
| **`S`** | **Flash Treesitter** | Instantly select code nodes (functions, blocks). |
| **`.`** | **Dot Repeat** | Fully supported for `mini.surround` and `neocodeium`. |

---

## 📂 Navigation & UI Features

| Keybind | Action | Description |
| :--- | :--- | :--- |
| **`<leader>e`** | **Neo-tree** | Toggle the standard file explorer sidebar. |
| **`<leader>fm`** | **Mini-Files** | Modern, interactive floating file manager. |
| **`<leader>ff`** | **Find Files** | Standard Telescope search for project files. |
| **`<leader>sg`** | **Live Grep** | Search for text across your entire project. |
| **`<leader>bd`** | **Close Buffer** | Close the current file/buffer. |

---

## ☯️ Clojure & Lisp (Interactive REPL)

| Keybind | Action | Description |
| :--- | :--- | :--- |
| **`,`** | **Conjure Prefix** | The main prefix for all REPL operations. |
| **`,ee`** | **Eval Exp** | Evaluate the current form under the cursor. |
| **`,eb`** | **Eval Buffer** | Evaluate the entire file. |
| **`,er`** | **Eval Root** | Evaluate the outermost form. |
| **`,lv`** | **Log View** | Toggle the REPL log (HUD) window. |
| **`,ls`** | **Log Split** | Open the REPL log in a persistent split. |
| **Parinfer** | **Auto-Indent** | Structural editing is automatic (just type!). |

---

## 💎 Ruby on Rails (vim-rails)

| Keybind | Action | Description |
| :--- | :--- | :--- |
| **`:A`** | **Alternate File** | Switch between controller and view, or model and spec. |
| **`:Rextract`** | **Extract Partial** | Extract selected view code into a partial. |
| **`:Rgenerate`** | **Rails Generate** | Run `rails generate` inside nvim. |
| **`:Rcontroller`** | **Go to Controller** | Jump to a controller by name. |
| **`:Rmodel`** | **Go to Model** | Jump to a model by name. |
| **`:Rview`** | **Go to View** | Jump to a view by name. |

---

## 💡 AI Provider Tips

1. **Gemini (Cloud)**: Your primary high-reasoning model. Requires `GEMINI_API_KEY`.
2. **Ollama (Local)**: Configured for `qwen2.5-coder:14b`. Runs completely offline.
3. **LM Studio (Local)**: Connects to your AppImage instance on port `1234`.
4. **NeoCodeium**: If you see "ghost text" you like, press **Alt+f**. If it flickers, it's because it's generating a multi-line suggestion—just wait a split second!

---

## 📖 Viewing this Cheatsheet
To view this file with beautiful formatting inside Neovim, run:
**`:Glow`**
