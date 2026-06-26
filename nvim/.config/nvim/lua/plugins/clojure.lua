return {
  -- Parinfer: For effortless structural editing in Clojure
  {
    "gpanders/nvim-parinfer",
    ft = { "clojure", "scheme", "lisp", "racket" },
  },

  -- Conjure: For REPL-driven development
  {
    "Olical/conjure",
    ft = { "clojure", "fennel", "python" }, -- and more
    config = function()
      -- Example configuration: ensure Conjure uses the right prefix
      vim.g["conjure#mapping#prefix"] = ","
    end,
  },

  -- Clojure LSP
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        clojure_lsp = {},
      },
    },
  },
}
