local function is_work_project()
  local cwd = vim.fn.getcwd()
  local work_dir = vim.fn.expand("~/Work")
  return cwd:sub(1, #work_dir) == work_dir
end

return {
  "supermaven-inc/supermaven-nvim",
  cond = not is_work_project(),
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
