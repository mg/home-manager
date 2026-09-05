-- https://github.com/kevinhwang91/nvim-hlslens

return {
  src = "https://github.com/kevinhwang91/nvim-hlslens",
  config = function()
    local hlslens = require("hlslens")
    hlslens.setup()

    local function search(key)
      return function()
        vim.cmd("normal! " .. vim.v.count1 .. key)
        hlslens.start()
      end
    end

    vim.keymap.set("n", "n", search("n"), { desc = "Next search match" })
    vim.keymap.set("n", "N", search("N"), { desc = "Previous search match" })
  end,
}
