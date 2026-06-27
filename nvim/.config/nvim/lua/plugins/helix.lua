-- Helix-style keybindings with toggle
-- Movement keys always highlight selection (enter Visual mode first)
-- Operators work in both Normal (no selection) and Visual (active selection)

local helix_maps = {}

vim.g.helix_mode = false

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
  -- Movement: enter Visual mode first, so selection follows cursor
  local function move(lhs, cmd, desc)
    map("n", lhs, function()
      local c = vim.v.count > 0 and tostring(vim.v.count) or ""
      vim.cmd("normal! v" .. c .. cmd)
    end, desc)
  end

  move("w", "w", "select word forward")
  move("b", "b", "select word backward")
  move("e", "e", "select word end")
  move("j", "j", "select down")
  move("k", "k", "select up")
  move("h", "h", "select left")
  move("l", "l", "select right")
  move("}", "}", "select paragraph forward")
  move("{", "{", "select paragraph backward")
  move("0", "0", "select to line start")
  move("$", "$", "select to line end")
  move("^", "^", "select to first non-blank")
  move("G", "G", "select to end")
  move("%", "%", "select matching bracket")
  move("(", "(", "select sentence backward")
  move(")", ")", "select sentence forward")
  move("gg", "gg", "select to top")

  -- Selection commands (work in Normal AND Visual)
  map({ "n", "v" }, "x", "V", "select line")

  map({ "n", "v" }, "X", function()
    local l = vim.fn.line(".")
    if l > 1 then
      vim.api.nvim_win_set_cursor(0, { l - 1, 0 })
      vim.cmd("normal! Vj")
    end
  end, "shrink selection")

  -- Duplicate (Normal: yyp, Visual: yank selection then paste)
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

  -- Tree-sitter expand/shrink selection
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
