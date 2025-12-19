-- https://github.com/carlos-algms/agentic.nvim

return {
  "carlos-algms/agentic.nvim",
  event = "VeryLazy",
  -- provider = "claude-acp",
  config = function()
    local cwd = vim.fn.getcwd()
    local work_dir = vim.fn.expand("~/Work")
    local provider = "claude-acp"

    -- Use opencode-acp for projects under ~/Work
    if string.find(cwd, work_dir, 1, true) == 1 then
      provider = "opencode-acp"
    end

    require("agentic").setup({
      provider = provider,
    })
  end,

  -- these are just suggested keymaps; customize as desired
  keys = {
    {
      "<C-\\>",
      function()
        require("agentic").toggle()
      end,
      mode = { "n", "v", "i" },
      desc = "Toggle Agentic Chat",
    },
    {
      "<C-'>",
      function()
        require("agentic").add_selection_or_file_to_context()
      end,
      mode = { "n", "v" },
      desc = "Add file or selection to Agentic to Context",
    },
    {
      "<C-,>",
      function()
        require("agentic").new_session()
      end,
      mode = { "n", "v", "i" },
      desc = "New Agentic Session",
    },
  },
}
