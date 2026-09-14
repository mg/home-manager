return {
  src = "file:///Users/mg/Projects/nvim/pluck",
  config = function()
    require("pluck").setup({
      window = {
        style = "float",
      },
    })
  end,
  keys = {
    {
      "<leader>ap",
      function()
        require("pluck").pick()
      end,
      desc = "Pick Agent Session",
    },
  },
}
