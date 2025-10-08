-- https://github.com/luckasRanarison/tailwind-tools.nvim?tab=readme-ov-file

return {
  {
    "luckasRanarison/tailwind-tools.nvim",
    lazy = true,
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    opts = {}, -- your configuration
    ft = { "html", "svelte", "astro", "vue", "typescriptreact", "elixir" },
  },
  {
    "razak17/tailwind-fold.nvim",
    opts = {
      min_chars = 50,
    },
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    ft = { "html", "svelte", "astro", "vue", "typescriptreact", "elixir" },
  },

  {
    "MaximilianLloyd/tw-values.nvim",
    keys = {
      { "<Leader>cv", "<CMD>TWValues<CR>", desc = "Tailwind CSS values" },
    },
    ft = { "html", "svelte", "astro", "vue", "typescriptreact", "elixir" },
    opts = {
      border = "rounded", -- Valid window border style,
      show_unknown_classes = true, -- Shows the unknown classes popup
    },
  },
}
