return {
  "akinsho/flutter-tools.nvim",
  lazy = true,
  dependencies = {
    "nvim-lua/plenary.nvim",
    "stevearc/dressing.nvim", -- optional for vim.ui.select
  },
  config = function()
    require("flutter-tools").setup({
      lsp = {
        color = { -- show the derived colors for dart variables
          enabled = true,
        },
        on_attach = function(client, bufnr)
          -- Your keybindings here if needed
        end,
        capabilities = require("cmp_nvim_lsp").default_capabilities(),
      },
      -- Optional: Enable Flutter DevTools
      dev_tools = {
        autostart = false,
        auto_open_browser = false,
      },
      -- Optional: Set specific outline settings
      outline = {
        open_cmd = "30vnew",
        auto_open = false,
      },
    })
  end,
}
