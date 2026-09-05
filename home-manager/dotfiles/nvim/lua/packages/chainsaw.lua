-- https://github.com/chrisgrieser/nvim-chainsaw

return {
  src = "https://github.com/chrisgrieser/nvim-chainsaw",
  config = function()
    require("chainsaw").setup({})
  end,
  keys = {
    {
      "<leader>cv",
      function() require("chainsaw").variableLog() end,
      mode = { "n", "x" },
      desc = "Log variable",
    },
  },
}
