return {
  src = "https://github.com/Wansmer/treesj",
  config = function()
    require("treesj").setup({
      use_default_keymaps = false,
    })
  end,
  keys = {
    { "<leader>M", function() require("treesj").toggle() end, desc = "Toggle split/join" },
    { "<leader>cJ", function() require("treesj").join() end, desc = "Join" },
    { "<leader>cS", function() require("treesj").split() end, desc = "Split" },
  },
}
