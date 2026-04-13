-- https://github.com/nvim-treesitter/nvim-treesitter-context

return {
  "nvim-treesitter/nvim-treesitter-context",
  config = function()
    require("treesitter-context").setup({
      enable = true,
    })
  end,
}
