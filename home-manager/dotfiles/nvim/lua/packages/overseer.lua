return {
  src = "https://github.com/stevearc/overseer.nvim",
  config = function()
    local overseer = require("overseer")

    overseer.setup({
      component_aliases = {
        default = {
          "on_exit_set_status",
          "on_complete_notify",
          { "on_complete_dispose", require_view = { "SUCCESS", "FAILURE" } },
          { "open_output", on_start = "always", direction = "tab", focus = true },
          "user.close_output_tab",
        },
      },
    })

    vim.keymap.set("n", "<leader>tr", ":OverseerRun<CR>", { desc = "[r]un task" })

    -- Start insert mode when overseer opens a terminal tab
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "OverseerOutput",
      callback = function(args)
        vim.schedule(function()
          if vim.api.nvim_get_current_buf() == args.buf then
            vim.cmd("startinsert")
          end
        end)
      end,
    })
  end,
}
