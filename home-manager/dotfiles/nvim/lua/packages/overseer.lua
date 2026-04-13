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
        },
      },
    })

    -- Register custom component to auto-close output tab on success
    overseer.register_component({
      name = "close_output_tab",
      desc = "Close the output tab when task completes successfully",
      constructor = function()
        return {
          on_complete = function(_, _, status)
            vim.schedule(function()
              if status == "FAILURE" then return end
              for _, tabpage in ipairs(vim.api.nvim_list_tabpages()) do
                for _, win in ipairs(vim.api.nvim_tabpage_list_wins(tabpage)) do
                  local buf = vim.api.nvim_win_get_buf(win)
                  if vim.bo[buf].filetype == "OverseerOutput" then
                    vim.api.nvim_set_current_tabpage(tabpage)
                    vim.cmd("tabclose")
                    return
                  end
                end
              end
            end)
          end,
        }
      end,
    })

    -- Add the component to all tasks via template hook
    overseer.add_template_hook({}, function(task_defn, util)
      util.add_component(task_defn, "close_output_tab")
    end)

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
