return {
  src = "https://github.com/folke/which-key.nvim",
  config = function()
    require("which-key").setup({ preset = "classic" })
    require("which-key").add({
      { "<leader>c", group = "[C]ode" },
      { "<leader>d", group = "[D]ocument" },
      { "<leader>r", group = "[R]ename" },
      { "<leader>s", group = "[S]earch" },
      { "<leader>sg", group = "[G]rug" },
      { "<leader>g", group = "[G]it" },
      { "<leader>gd", group = "[D]iff" },
      { "<leader>gh", group = "[H]unk", mode = { "n", "v" } },
      { "<leader>gl", group = "[L]og" },
      { "<leader>gt", group = "[T]oggle" },
      { "<leader>w", group = "[W]orkspace" },
      { "<leader>t", group = "[T]oggle" },
    })
  end,
}
