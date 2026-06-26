-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- Soften diagnostic underlines across all themes
-- Replaces undercurl (squiggly) with flat underline, preserves theme colors
vim.api.nvim_create_autocmd("ColorScheme", {
  group = vim.api.nvim_create_augroup("SoftDiag", { clear = true }),
  callback = function()
    for _, sev in ipairs({ "Error", "Warn", "Info", "Hint" }) do
      local hl = vim.api.nvim_get_hl(0, { name = "DiagnosticUnderline" .. sev })
      hl.undercurl = nil
      hl.underline = true
      vim.api.nvim_set_hl(0, "DiagnosticUnderline" .. sev, hl)
    end
  end,
})
