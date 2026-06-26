return {
  {
    "folke/zen-mode.nvim",
    cmd = "ZenMode",
    opts = {
      window = {
        backdrop = 0.95,
        width = 80,
        height = 1,
        options = {
          number = true,
          relativenumber = false,
          cursorline = false,
          cursorcolumn = false,
        },
      },
      plugins = {
        options = {
          enabled = true,
          ruler = false,
          showcmd = false,
        },
        twilight = { enabled = true },
      },
    },
    keys = {
      {
        "<leader>tw",
        function()
          vim.o.background = "light"
          require("zen-mode").toggle()
        end,
        desc = "Writer's Mode",
      },
    },
  },
  {
    "folke/twilight.nvim",
    opts = {},
  },
}
