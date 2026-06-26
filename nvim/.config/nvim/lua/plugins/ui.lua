return {
  -- Catppuccin theme
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    opts = {
      flavour = "mocha", -- latte, frappe, macchiato, mocha
      transparent_background = false,
      integrations = {
        mini = true,
        notify = true,
        telescope = true,
        lsp_trouble = true,
        which_key = true,
        navic = { enabled = true, custom_bg = "lualine" },
        neotree = true,
        render_markdown = true,
      },
    },
  },

  -- LazyVim colorscheme selection
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "gruvbox",
    },
  },

  -- Noice: Better UI for messages, cmdline, etc.
  {
    "folke/noice.nvim",
    opts = {
      lsp = {
        override = {
          ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
          ["vim.lsp.util.set_formatting_string"] = true,
          ["nvim-treesitter.styling.markdown_lines"] = true,
        },
      },
      presets = {
        bottom_search = true,
        command_palette = true,
        long_message_to_split = true,
        inc_rename = true,
      },
    },
  },
}
