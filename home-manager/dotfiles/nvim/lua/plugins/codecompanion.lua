local function is_work_project()
  local cwd = vim.fn.getcwd()
  local work_dir = vim.fn.expand("~/Work")
  return cwd:sub(1, #work_dir) == work_dir
end

return {
  "olimorris/codecompanion.nvim",
  cond = is_work_project,
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
