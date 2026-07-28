return {
  desc = "Close the output tab when task completes successfully",
  constructor = function()
    return {
      on_complete = function(_, task, status)
        vim.schedule(function()
          if status == "FAILURE" then return end

          -- `just search` is an informational command; keep its output open so it
          -- can be read. Closing the Overseer output tab as soon as it completes
          -- also sometimes races with the terminal window and causes
          -- "Invalid window id".
          if task and task.name and task.name:match("^just search") then return end

          for _, tabpage in ipairs(vim.api.nvim_list_tabpages()) do
            if vim.api.nvim_tabpage_is_valid(tabpage) then
              for _, win in ipairs(vim.api.nvim_tabpage_list_wins(tabpage)) do
                if vim.api.nvim_win_is_valid(win) then
                  local buf = vim.api.nvim_win_get_buf(win)
                  if vim.bo[buf].filetype == "OverseerOutput" then
                    pcall(vim.api.nvim_set_current_tabpage, tabpage)
                    pcall(vim.cmd, "tabclose")
                    return
                  end
                end
              end
            end
          end
        end)
      end,
    }
  end,
}
