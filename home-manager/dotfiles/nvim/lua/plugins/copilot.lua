vim.api.nvim_create_autocmd("User", {
  pattern = "CopilotAuth",
  callback = function()
    -- Silently handle auth errors
    pcall(function()
      vim.cmd("Copilot auth")
    end)
  end,
})

local function is_work_project()
  local cwd = vim.fn.getcwd()
  local work_dir = vim.fn.expand("~/Work")
  return cwd:sub(1, #work_dir) == work_dir
end

return {
  "zbirenbaum/copilot.lua",
  cond = is_work_project(),
  event = "BufRead",
  config = function()
    require("copilot").setup({
      suggestion = {
        enabled = true,
        auto_trigger = true,
        keymap = {
          accept = "<C-]>",
          dismiss = "<C-c>",
        },
      },
      panel = { enabled = true },
    })
  end,
}
