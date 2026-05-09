-- https://github.com/esmuellert/codediff.nvim

return {
  "esmuellert/codediff.nvim",
  cmd = { "CodeDiff" },
  keys = {
    { "<leader>gdc", "<cmd>CodeDiff<cr>", desc = "CodeDiff changes" },
    { "<leader>gdC", "<cmd>CodeDiff file HEAD<cr>", desc = "CodeDiff current file" },
    { "<leader>gdH", "<cmd>CodeDiff history<cr>", desc = "CodeDiff history" },
  },
  opts = {},
}
