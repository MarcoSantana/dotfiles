return {
  -- vim-rails: Navigation and project management for Ruby on Rails
  {
    "tpope/vim-rails",
    event = "VeryLazy",
  },

  -- Ruby LSP and formatting
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        ruby_lsp = {},
        solargraph = {
          enabled = false, -- ruby_lsp is preferred
        },
      },
    },
  },
}
