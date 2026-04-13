require("vim._core.ui2").enable({})
require("opt")
if vim.go.loadplugins then
  require("packages")
end
require("builtin")
require("keymaps")
require("autocommands")
require("functions")
require("lsp")

if vim.go.loadplugins then
  vim.pack.add({ 'https://github.com/zuqini/zpack.nvim' })
  require('zpack').setup()
end
