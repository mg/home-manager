return { -- Highlight, edit, and navigate code
  "nvim-treesitter/nvim-treesitter",
  branch = "main",
  build = ":TSUpdate",
  event = { "BufReadPre", "BufNewFile" },
  opts = {
    auto_install = true,
  },
  init = function()
    local ensureInstalled = {
      "bash",
      "c",
      "diff",
      "html",
      "lua",
      "luadoc",
      "markdown",
      "vim",
      "vimdoc",
      "python",
      "zig",
      "typescript",
      "tsx",
      "json",
      "gitignore",
      "yaml",
      "css",
      "elixir",
      "eex",
      "heex",
    }

    vim.api.nvim_create_autocmd("FileType", {
      callback = function()
        -- Enable treesitter highlighting and disable regex syntax
        pcall(vim.treesitter.start)
        -- Enable treesitter-based indentation
        vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
      end,
    })

    -- Install missing parsers on startup
    vim.api.nvim_create_autocmd("User", {
      pattern = "LazyDone",
      once = true,
      callback = function()
        local ok, config = pcall(require, "nvim-treesitter.config")
        if not ok then return end
        local installed = config.get_installed()
        local to_install = vim.iter(ensureInstalled)
          :filter(function(parser)
            return not vim.tbl_contains(installed, parser)
          end)
          :totable()
        if #to_install > 0 then
          require("nvim-treesitter").install(to_install)
        end
      end,
    })
  end,
  config = function(_, opts)
    require("nvim-treesitter").setup(opts)
  end,
}
