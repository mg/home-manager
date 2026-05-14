return {
  src = "https://github.com/YousefHadder/markdown-plus.nvim",
  config = function()
    local loaded = false

    local function setup_markdown_plus()
      if loaded then
        return
      end

      loaded = true
      pcall(vim.cmd.packadd, "markdown-plus.nvim")
      require("markdown-plus").setup({
        filetypes = { "markdown" },
      })
    end

    vim.api.nvim_create_autocmd("FileType", {
      pattern = "markdown",
      once = true,
      callback = setup_markdown_plus,
    })

    if vim.bo.filetype == "markdown" then
      setup_markdown_plus()
    end
  end,
}
