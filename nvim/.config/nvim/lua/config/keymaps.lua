-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Toggle group label for which-key
vim.keymap.set("n", "<leader>t", "<nop>", { desc = "+Toggle" })

-- Toggle spellcheck
vim.keymap.set("n", "<leader>ts", function()
  vim.opt.spell = not vim.opt.spell:get()
  vim.notify("Spell: " .. (vim.opt.spell:get() and "ON" or "OFF"))
end, { desc = "Toggle spellcheck" })

-- Cycle spell language
vim.keymap.set("n", "<leader>tl", function()
  local langs = { "es", "en" }
  local cur = vim.opt.spelllang:get()[1]
  local next_lang = cur == langs[1] and langs[2] or langs[1]
  vim.opt.spelllang = next_lang
  vim.notify("Spell lang: " .. next_lang)
end, { desc = "Cycle spell language" })

-- Typst code/text toggle
vim.api.nvim_create_autocmd("FileType", {
  pattern = "typst",
  callback = function()
    vim.keymap.set("n", "<leader>tc", function()
      vim.opt.spell = not vim.opt.spell:get()
      vim.notify("Mode: " .. (vim.opt.spell:get() and "Text" or "Code"))
    end, { buffer = true, desc = "Toggle Typst mode" })
  end,
})

-- Toggle Light/Dark Theme
vim.keymap.set("n", "<leader>bg", function()
  if vim.o.background == "dark" then
    vim.o.background = "light"
  else
    vim.o.background = "dark"
  end
  vim.cmd([[doautoall ColorScheme]])
end, { desc = "Toggle Theme (Light/Dark)" })

-- [[ Emacs-style keybindings (insert & command-line modes) ]]

local function kill_to_end()
  local row, col = unpack(vim.api.nvim_win_get_cursor(0))
  local line = vim.api.nvim_get_current_line()
  local rest = line:sub(col + 1)
  if rest ~= "" then
    vim.fn.setreg('"', rest, "c")
    vim.api.nvim_buf_set_text(0, row - 1, col, row - 1, #line, { "" })
  end
end

-- Word-level movements (Alt/Meta)
vim.keymap.set({ "i", "c" }, "<M-b>", "<C-Left>", { desc = "Emacs: backward word" })
vim.keymap.set({ "i", "c" }, "<M-f>", "<C-Right>", { desc = "Emacs: forward word" })
vim.keymap.set("i", "<M-d>", "<C-o>de", { desc = "Emacs: delete word forward" })
vim.keymap.set({ "i", "c" }, "<M-BS>", "<C-w>", { desc = "Emacs: delete word backward" })

-- Character-level movements
vim.keymap.set({ "i", "c" }, "<C-f>", "<Right>", { desc = "Emacs: forward char" })
vim.keymap.set({ "i", "c" }, "<C-b>", "<Left>", { desc = "Emacs: backward char" })
vim.keymap.set({ "i", "c" }, "<C-a>", "<Home>", { desc = "Emacs: beginning of line" })

-- Deletion
vim.keymap.set({ "i", "c" }, "<C-d>", "<Del>", { desc = "Emacs: delete char forward" })
vim.keymap.set("i", "<C-k>", kill_to_end, { desc = "Emacs: kill to end of line" })

-- Paste
vim.keymap.set({ "i", "c" }, "<C-y>", '<C-r>"', { desc = "Emacs: yank (paste)" })

-- Page movements (insert mode only)
vim.keymap.set("i", "<M-v>", "<PageUp>", { desc = "Emacs: page up" })

-- [[ Gentle diagnostic distraction toggles ]]

-- Cycle diagnostic visibility: All → Warn+ → Errors → Off
vim.keymap.set("n", "<leader>td", function()
  local states = {
    { severity = nil, desc = "All" },
    { severity = { min = vim.diagnostic.severity.WARN }, desc = "Warn+" },
    { severity = { min = vim.diagnostic.severity.ERROR }, desc = "Errors" },
    { enable = false, desc = "Off" },
  }
  local idx = (vim.g.diag_level or 0) % #states + 1
  vim.g.diag_level = idx
  local s = states[idx]
  if s.enable == false then
    vim.diagnostic.enable(false)
  else
    vim.diagnostic.enable(true)
    vim.diagnostic.config({ severity = s.severity })
  end
  vim.notify("Diag: " .. s.desc)
end, { desc = "Cycle diagnostic level" })

-- Toggle virtual text independently
vim.keymap.set("n", "<leader>tD", function()
  local cur = vim.diagnostic.config().virtual_text
  vim.diagnostic.config({ virtual_text = not cur })
  vim.notify("Virtual text: " .. (not cur and "ON" or "OFF"))
end, { desc = "Toggle virtual text" })
