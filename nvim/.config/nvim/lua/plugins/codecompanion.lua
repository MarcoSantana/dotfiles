return {
  "olimorris/codecompanion.nvim",
  cmd = { "CodeCompanion", "CodeCompanionChat", "CodeCompanionActions", "CodeCompanionCmd" },
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
    "stevearc/dressing.nvim", -- Required for nice UI
    "nvim-telescope/telescope.nvim", -- Optional but useful
  },
  opts = function()
    return {
      strategies = {
        chat = {
          adapter = "ollama",
          keymaps = {
            send = {
              modes = { n = { "<CR>", "<C-s>" }, i = { "<C-s>", "<C-CR>" } },
              index = 1,
              callback = "keymaps.send",
              description = "Send message",
            },
            close = {
              modes = { n = "q", i = "<C-c>" },
              index = 3,
              callback = "keymaps.close",
              description = "Close chat",
            },
          },
        },
        inline = {
          adapter = "ollama",
        },
        agent = {
          adapter = "ollama",
        },
      },
      adapters = {
        ollama = function()
          return require("codecompanion.adapters").extend("ollama", {
            env = {
              url = "http://localhost:11434",
            },
            schema = {
              model = {
                default = "ollama_chat/qwen2.5-coder:14b"
              },
            },
          })
        end,
      },
      display = {
        chat = {
          show_settings = true,
          render_headers = true,
        },
      },
    }
  end,
}
