return {
  -- otter.nvim: LSP features for code blocks in markdown
  {
    "jmbuhr/otter.nvim",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
    },
    opts = {
      buffers = {
        set_filetype = true,
      },
    },
    config = function(_, opts)
      local otter = require("otter")
      otter.setup(opts)

      -- Automatically activate otter in markdown files
      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "markdown" },
        callback = function()
          otter.activate({ "lua", "ruby", "clojure" })
        end,
      })
    end,
  },
}
