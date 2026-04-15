-- https://github.com/sindrets/diffview.nvim

return {
  "dlyongemallo/diffview.nvim",
  cmd = { "DiffviewOpen", "DiffviewFileHistory" },
  keys = {
    { "<leader>gdv", "<cmd>DiffviewOpen<cr>",          desc = "Open diff[v]iew" },
    { "<leader>gdf", "<cmd>DiffviewFileHistory %<cr>", desc = "[F]ile history" },
    { "<leader>gdF", "<cmd>DiffviewFileHistory<cr>",   desc = "Branch history" },
  },
  opts = {},
}
