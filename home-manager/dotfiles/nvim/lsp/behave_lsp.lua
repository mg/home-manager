vim.filetype.add({
  extension = {
    feature = "cucumber",
  },
})

---@brief
--- https://github.com/HosseyNJF/behave-lsp.nvim
---
--- Language server for behave BDD feature files and Python step definitions.

---@type vim.lsp.Config
return {
  cmd = { "behave-lsp" },
  filetypes = { "cucumber", "feature", "gherkin", "python" },
  root_markers = { "behave.ini", "pyproject.toml", "setup.cfg", "tox.ini", ".git" },
}
