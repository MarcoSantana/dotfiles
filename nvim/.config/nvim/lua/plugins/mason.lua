return {
  {
    "mason-org/mason.nvim",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, {
        "ruby-lsp",
        "solargraph",
        "clojure-lsp",
        "tinymist",
        "ltex-ls",
      })
    end,
  },
}
