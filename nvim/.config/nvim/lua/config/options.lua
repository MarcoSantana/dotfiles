-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

vim.opt.spelllang = "es"

vim.opt.list = true
vim.opt.listchars = {
  eol = "↲",
  tab = "→ ",
  trail = "·",
  extends = "⟩",
  precedes = "⟨",
  nbsp = "␣",
}

vim.opt.showbreak = "↪ "
vim.opt.breakindent = true
vim.opt.breakindentopt = "sbr"

-- Register space-lua as lua for treesitter highlighting in markdown blocks
vim.treesitter.language.register("lua", "space-lua")

-- Softer diagnostic defaults
vim.diagnostic.config({
  virtual_text = false,
  signs = true,
  underline = true,
  update_in_insert = false,
  severity_sort = true,
})
