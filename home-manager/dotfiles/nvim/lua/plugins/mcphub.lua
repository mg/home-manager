-- https://ravitemer.github.io/mcphub.nvim

return {
  "ravitemer/mcphub.nvim",
  lazy = true,
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
  build = "bun install -g mcp-hub@latest", -- Installs `mcp-hub` node binary globally
  config = function()
    require("mcphub").setup()
  end,
}
