-- Helix-style keybindings with toggle

local helix_maps = {}

vim.g.helix_mode = false

local function apply_helix()
  local function map(mode, lhs, rhs, desc)
    vim.keymap.set(mode, lhs, rhs, { desc = "[Helix] " .. desc })
    table.insert(helix_maps, { mode, lhs })
  end

  map("n", "x", "V", "select line")
  map("n", "X", function()
    local l = vim.fn.line(".")
    if l > 1 then
      vim.api.nvim_win_set_cursor(0, { l - 1, 0 })
      vim.cmd("normal! Vj")
    end
  end, "shrink selection")
  map("n", "C", "<cmd>yyp<cr>", "duplicate line down")
  map("n", "<A-C>", function()
    local l = vim.fn.line(".")
    if l > 1 then
      vim.api.nvim_win_set_cursor(0, { l - 1, 0 })
      vim.cmd("normal! yyp")
      vim.api.nvim_win_set_cursor(0, { l, 0 })
    end
  end, "duplicate line up")
  map("n", "<A-o>", function()
    require("nvim-treesitter.ts_utils").update_selection(vim.fn.getpos("."))
  end, "expand selection")
  map("n", "<A-i>", function()
    local pos = vim.fn.getpos(".")
    local ok, node = pcall(vim.treesitter.get_node)
    if ok and node and node:parent() then
      local sr, sc, er, ec = node:range()
      if er - sr > 1 then
        vim.api.nvim_win_set_cursor(0, { sr + 1, sc })
      end
    end
  end, "shrink selection")
  map("n", "<A-n>", "<cmd>normal! ]m<cr>", "next sibling")
  map("n", "<A-p>", "<cmd>normal! [m<cr>", "prev sibling")
  map("n", "<A-k>", "<cmd>lua vim.diagnostic.goto_next()<cr>", "next diagnostic")
  map("n", "<A-j>", "<cmd>lua vim.diagnostic.goto_prev()<cr>", "prev diagnostic")
end

local function remove_helix()
  for _, m in ipairs(helix_maps) do
    pcall(vim.keymap.del, m[1], m[2])
  end
  helix_maps = {}
end

function _G.toggle_helix_mode()
  vim.g.helix_mode = not vim.g.helix_mode
  if vim.g.helix_mode then
    apply_helix()
  else
    remove_helix()
  end
  vim.notify("Helix mode: " .. (vim.g.helix_mode and "⚡ ON" or "OFF"))
end

vim.keymap.set("n", "<leader>th", _G.toggle_helix_mode, { desc = "Toggle Helix mode" })

return {
  -- Statusline: ⚡ icon when Helix mode is active
  {
    "nvim-lualine/lualine.nvim",
    optional = true,
    opts = function(_, opts)
      table.insert(opts.sections.lualine_x, 1, {
        function() return " ⚡" end,
        cond = function() return vim.g.helix_mode end,
      })
    end,
  },
}
