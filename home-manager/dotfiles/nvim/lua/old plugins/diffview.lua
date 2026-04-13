-- https://github.com/sindrets/diffview.nvim

return {
  "sindrets/diffview.nvim",
  cmd = { "DiffviewOpen", "DiffviewFileHistory" },
  keys = {
    { "<leader>hv", "<cmd>DiffviewOpen<cr>", desc = "Open diff[v]iew" },
    { "<leader>hf", "<cmd>DiffviewFileHistory %<cr>", desc = "File history" },
    { "<leader>hF", "<cmd>DiffviewFileHistory<cr>", desc = "Branch history" },
  },
  opts = {},
}
