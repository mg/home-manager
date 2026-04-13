return {
  desc = "Close the output tab when task completes",
  constructor = function()
    return {
      on_complete = function(self, task, status)
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
}
