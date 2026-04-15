return {
  "supermaven-inc/supermaven-nvim",
  cond = not require("lib").is_work_dir(),
  event = "BufRead",
  config = function()
    require("supermaven-nvim").setup({
      keymaps = {
        accept_suggestion = "<C-f>",
        clear_suggestion = "<C-c>",
      },
      disable_inline_completion = false,
    })
  end,
}
