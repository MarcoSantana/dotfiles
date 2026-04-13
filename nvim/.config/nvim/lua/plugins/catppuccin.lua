---@type LazySpec
return {
  {
    "catppuccin/nvim",
    name = "catppuccin", -- provide the name to ensure it matches the one from astrocommunity
    opts = {
      transparent_background = false,
      flavour = "mocha", -- you can change this to "latte", "frappe", or "macchiato"
      integrations = {
        neotree = true,
        treesitter = true,
        notify = true,
        -- ... any others
      },
    },
  },
}
