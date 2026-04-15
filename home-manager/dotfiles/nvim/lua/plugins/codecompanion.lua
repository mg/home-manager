return {
  "olimorris/codecompanion.nvim",
  cond = require("lib").is_work_dir,
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
  cmd = { "CodeCompanion", "CodeCompanionChat", "CodeCompanionActions" },
  keys = {
    { "<leader>cc", "<cmd>CodeCompanionChat Toggle<cr>", mode = { "n", "v" }, desc = "CodeCompanion Chat" },
    { "<leader>ca", "<cmd>CodeCompanionActions<cr>", mode = { "n", "v" }, desc = "CodeCompanion Actions" },
  },
  config = function()
    require("codecompanion").setup({
      adapters = {
        copilot = function()
          return require("codecompanion.adapters").extend("copilot", {})
        end,
      },
      strategies = {
        chat = { adapter = "copilot" },
        inline = { adapter = "copilot" },
        cmd = { adapter = "copilot" },
      },
    })
  end,
}
