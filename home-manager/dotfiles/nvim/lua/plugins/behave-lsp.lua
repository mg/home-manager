return {
  "HosseyNJF/behave-lsp.nvim",
  lazy = false,
  build = function(plugin)
    vim.system({
      "uv",
      "tool",
      "install",
      "--from",
      vim.fs.joinpath(plugin.path, "lsp_server"),
      "--force",
      "--reinstall",
      "behave-lsp",
    }, { text = true }, function(result)
      vim.schedule(function()
        if result.code == 0 then
          vim.notify("behave-lsp installed", vim.log.levels.INFO)
        else
          vim.notify("behave-lsp install failed:\n" .. (result.stderr or result.stdout or ""), vim.log.levels.ERROR)
        end
      end)
    end)
  end,
}
