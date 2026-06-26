return {
  -- Avante: Cursor-like AI experience in Neovim
  {
    "yetone/avante.nvim",
    event = "VeryLazy",
    lazy = false,
    version = false, -- set this if you want to always pull the latest change
    opts = {
      provider = "gemini",
      auto_suggestions_provider = "gemini",
      providers = {
        gemini = {
          model = "gemini-1.5-pro",
          timeout = 30000,
          extra_request_body = {
            generationConfig = {
              temperature = 0,
              max_output_tokens = 4096,
            },
          },
        },
        ollama = {
          __inherited_from = "openai",
          api_key_name = "",
          endpoint = "http://127.0.0.1:11434/v1",
          model = "qwen2.5-coder:14b",
        },
        lmstudio = {
          __inherited_from = "openai",
          api_key_name = "",
          endpoint = "http://127.0.0.1:1234/v1",
          model = "qwen2.5-coder-14b-instruct", -- Change this if you load a different model in LM Studio
        },
      },
      behaviour = {
        auto_suggestions = true,
      },
      hints = { enabled = true },
      windows = {
        sidebar_header = {
          enabled = true,
          align = "center",
          rounded = true,
        },
      },
      input = {
        provider = "snacks",
      },
      file_selector = {
        provider = "snacks",
      },
    },
    -- if you want to build from source then do `make BUILD_FROM_SOURCE=true`
    build = "make",
    dependencies = {
      "stevearc/dressing.nvim",
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      --- The below dependencies are optional,
      "nvim-tree/nvim-web-devicons", -- or echasnovski/mini.icons
      {
        -- support for image pasting
        "HakonHarnes/img-clip.nvim",
        event = "VeryLazy",
        opts = {
          -- recommended settings
          default = {
            embed_image_as_base64 = false,
            prompt_for_file_name = false,
            drag_and_drop = {
              insert_mode = true,
            },
            -- required for Windows users
            use_absolute_path = true,
          },
        },
      },
      {
        -- Make sure to set this up properly if you have lazy=true
        "MeanderingProgrammer/render-markdown.nvim",
        opts = {
          file_types = { "markdown", "Avante" },
          code = {
            background_inset = 1,
          },
        },
        ft = { "markdown", "Avante" },
      },
    },
  },

  -- NeoCodeium: Faster, more stable Codeium implementation for Neovim
  {
    "monkoose/neocodeium",
    event = "InsertEnter",
    config = function()
      local neocodeium = require("neocodeium")
      neocodeium.setup()
      vim.keymap.set("i", "<A-f>", neocodeium.accept)
    end,
  },

  -- nvim-aider: Aider integration
  {
    "GeorgesAlkhouri/nvim-aider",
    cmd = "Aider",
    keys = {
      { "<leader>A", group = "Aider" },
      { "<leader>Ai", "<cmd>Aider toggle<cr>", desc = "Toggle Aider" },
      { "<leader>As", "<cmd>Aider send<cr>", desc = "Send to Aider", mode = { "n", "v" } },
      { "<leader>Ac", "<cmd>Aider command<cr>", desc = "Aider Commands" },
      { "<leader>Ab", "<cmd>Aider buffer<cr>", desc = "Send Buffer" },
      { "<leader>Aa", "<cmd>Aider add<cr>", desc = "Add File" },
      { "<leader>Ad", "<cmd>Aider drop<cr>", desc = "Drop File" },
      { "<leader>Ar", "<cmd>Aider add readonly<cr>", desc = "Add Read-Only" },
      { "<leader>AR", "<cmd>Aider reset<cr>", desc = "Reset Session" },
    },
    dependencies = {
      "folke/snacks.nvim",
      "nvim-neo-tree/neo-tree.nvim",
    },
    init = function()
      vim.env.OLLAMA_API_BASE = "http://localhost:11434"
      vim.env.GEMINI_API_KEY = "AIzaSyB5z_Y-XuJ3CKIATohwOePfGPCW5N475ds"
    end,
    opts = {
      args = {
        "--model",
        "gemini/gemini-1.5-pro-latest",
        "--no-auto-commits",
        "--pretty",
        "--stream",
      },
      win = {
        style = "nvim_aider",
        position = "right",
      },
    },
  },
}
