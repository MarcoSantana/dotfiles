return {
  -- logseq-mode.nvim: Logseq integration for Neovim
  {
    "Conor-McLeod/logseq-mode.nvim",
    dependencies = {
      "stevearc/conform.nvim",
    },
    opts = {
      logseq_dir = "/extra/Dropbox/logseq/Diary",
    },
    config = function(_, opts)
      require("logseq_mode").setup(opts)

      -- Keybindings for Logseq
      vim.keymap.set("n", "<leader>nj", "<cmd>LogseqDaily<cr>", { desc = "Logseq Daily Journal" })
      
      -- Search Graph with Snacks
      vim.keymap.set("n", "<leader>ns", function()
        Snacks.picker.files({ cwd = opts.logseq_dir, prompt = "Logseq Search Graph " })
      end, { desc = "Logseq Search Graph" })
      
      vim.keymap.set("n", "<leader>ng", function()
        Snacks.picker.grep({ cwd = opts.logseq_dir, prompt = "Logseq Grep Graph " })
      end, { desc = "Logseq Grep Graph" })
    end,
  },
}
