return {
  {
    "ellisonleao/glow.nvim",
    config = true,
    cmd = "Glow",
    keys = {
      { "<leader>hc", "<cmd>Glow " .. vim.fn.stdpath("config") .. "/CHEATSHEET.md<cr>", desc = "Help: Cheatsheet (Glow)" },
    },
  },
}
