return {
  "GeorgesAlkhouri/nvim-aider",
  cmd = "Aider",
  keys = {
    { "<leader>a", group = "Aider" },
    { "<leader>ai", "<cmd>Aider toggle<cr>", desc = "Toggle Aider" },
    { "<leader>as", "<cmd>Aider send<cr>", desc = "Send to Aider", mode = { "n", "v" } },
    { "<leader>ac", "<cmd>Aider command<cr>", desc = "Aider Commands" },
    { "<leader>ab", "<cmd>Aider buffer<cr>", desc = "Send Buffer" },
    { "<leader>aa", "<cmd>Aider add<cr>", desc = "Add File" },
    { "<leader>ad", "<cmd>Aider drop<cr>", desc = "Drop File" },
    { "<leader>ar", "<cmd>Aider add readonly<cr>", desc = "Add Read-Only" },
    { "<leader>aR", "<cmd>Aider reset<cr>", desc = "Reset Session" },
  },
  dependencies = {
    "folke/snacks.nvim",
    "nvim-neo-tree/neo-tree.nvim",
  },
  init = function()
    -- Ensure Aider can find your local Ollama instance
    vim.env.OLLAMA_API_BASE = "http://localhost:11434"
  end,
  opts = {
    args = {
      "--model",
      "ollama_chat/qwen2.5-coder:14b",
      "--no-auto-commits",
      "--pretty",
      "--stream",
    },
    win = {
      style = "nvim_aider",
      position = "right",
    },
  },
}
