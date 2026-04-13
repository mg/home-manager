return {
  src = "https://github.com/nvim-treesitter/nvim-treesitter",
  config = function()
    local ensureInstalled = {
      "bash", "c", "diff", "html", "lua", "luadoc", "markdown",
      "vim", "vimdoc", "python", "zig", "typescript", "tsx",
      "json", "gitignore", "yaml", "css", "elixir", "eex", "heex",
    }

    require("nvim-treesitter").setup({
      auto_install = true,
    })

    vim.api.nvim_create_autocmd("FileType", {
      callback = function()
        pcall(vim.treesitter.start)
        vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
      end,
    })

    vim.api.nvim_create_autocmd("VimEnter", {
      once = true,
      callback = function()
        local ok, config = pcall(require, "nvim-treesitter.config")
        if not ok then return end
        local installed = config.get_installed()
        local to_install = vim.iter(ensureInstalled)
          :filter(function(parser) return not vim.tbl_contains(installed, parser) end)
          :totable()
        if #to_install > 0 then
          require("nvim-treesitter").install(to_install)
        end
      end,
    })
  end,
}
