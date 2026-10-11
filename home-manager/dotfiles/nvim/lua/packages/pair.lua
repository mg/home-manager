return {
  src = "https://github.com/mg/pair.nvim",
  version = "feat/pi-rpc-backend",
  config = function()
    require("pair").setup({
      backend = "pi",
    })
  end,
  keys = {
    {
      "<leader>pa",
      ":<C-u>PairAsk<CR>",
      mode = { "n", "x" },
      desc = "Pair Ask",
    },
  },
}
