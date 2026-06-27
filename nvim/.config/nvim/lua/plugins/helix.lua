-- Helix-style editing with AniMotion.nvim + operator overrides toggle
-- AniMotion handles selection-on-movement (w/b/e), always active
-- <leader>th toggles additional Helix operator overrides + ⚡ icon

local helix_maps = {}

vim.g.helix_mode = false

-- AniMotion: selection-first word movements (always on)
local function setup_animotion()
  require("AniMotion").setup({
    mode = "helix",
    edit_keys = {},           -- don't hook operators, we handle them
    clear_keys = { "<Esc>", ";", "<C-c>" },
  })
end

-- Helix operator overrides (toggled via <leader>th)
local function map(modes, lhs, rhs, desc)
  if type(modes) == "string" then
    modes = { modes }
  end
  for _, m in ipairs(modes) do
    vim.keymap.set(m, lhs, rhs, { desc = "[Helix] " .. desc })
    table.insert(helix_maps, { m, lhs })
  end
end

local function apply_helix()
  -- Selection commands
  map({ "n", "v" }, "x", "V", "select line")

  map({ "n", "v" }, "X", function()
    local l = vim.fn.line(".")
    if l > 1 then
      vim.api.nvim_win_set_cursor(0, { l - 1, 0 })
      vim.cmd("normal! Vj")
    end
  end, "shrink selection")

  -- Duplicate line
  map({ "n", "v" }, "C", function()
    local m = vim.fn.mode()
    if m == "n" or m == "no" then
      vim.cmd("normal! yyp")
    else
      vim.cmd("normal! ygvyp")
    end
  end, "duplicate line down")

  map({ "n", "v" }, "<A-C>", function()
    local l = vim.fn.line(".")
    if l > 1 then
      vim.api.nvim_win_set_cursor(0, { l - 1, 0 })
      vim.cmd("normal! yyp")
      vim.api.nvim_win_set_cursor(0, { l, 0 })
    end
  end, "duplicate line up")

  -- Tree-sitter expand/shrink
  map("n", "<A-o>", function()
    require("nvim-treesitter.ts_utils").update_selection(vim.fn.getpos("."))
  end, "expand selection")

  map("n", "<A-i>", function()
    local ok, node = pcall(vim.treesitter.get_node)
    if ok and node and node:parent() then
      local sr, sc = node:parent():range()
      if math.abs(vim.fn.line(".") - (sr + 1)) > 0 then
        vim.api.nvim_win_set_cursor(0, { sr + 1, sc })
      end
    end
  end, "shrink selection")

  -- Navigation
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
  {
    "luiscassih/AniMotion.nvim",
    event = "VeryLazy",
    config = setup_animotion,
  },

  -- Statusline: ⚡ icon
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
