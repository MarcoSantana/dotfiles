---@type LazySpec
return {
  "nvim-treesitter/nvim-treesitter",
  opts = {
    ensure_installed = {
      "lua",
      "vim",
      "typst",
      "markdown",
      "markdown_inline",
    },
  },
}
