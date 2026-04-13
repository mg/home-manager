return {
  src = "https://github.com/nvim-treesitter/nvim-treesitter",
  config = function()
    require("nvim-treesitter").setup({
      auto_install = true,
      ensure_installed = {
        "bash", "c", "diff", "html", "lua", "luadoc", "markdown",
        "markdown_inline", "vim", "vimdoc", "python", "zig",
        "typescript", "tsx", "json", "gitignore", "yaml", "css",
        "elixir", "eex", "heex",
      },
    })

    vim.api.nvim_create_autocmd("FileType", {
      callback = function()
        pcall(vim.treesitter.start)
        vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
      end,
    })
  end,
}
