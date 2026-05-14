-- https://github.com/dmtrKovalenko/fff.nvim

return {
  src = "https://github.com/dmtrKovalenko/fff.nvim",
  version = "v0.5.2",
  config = function()
    local dir = vim.fn.stdpath("data") .. "/site/pack/core/opt/fff.nvim"
    local dylib = dir .. "/target/release/libfff_nvim.dylib"
    if vim.fn.filereadable(dylib) == 0 then
      vim.fn.mkdir(dir .. "/target/release", "p")
      vim.fn.system({
        "curl", "-sL",
        "https://github.com/dmtrKovalenko/fff.nvim/releases/download/v0.5.2/aarch64-apple-darwin.dylib",
        "-o", dylib,
      })
    end

    require("fff").setup({
      layout = {
        height = 1.0,
        width = 1.0,
      }
    })

    vim.keymap.set("n", "ff", function() require("fff").find_files() end, { desc = "FFFind files" })
    vim.keymap.set("n", "fg", function() require("fff").live_grep() end, { desc = "LiFFFe grep" })
    vim.keymap.set("n", "fz", function()
      require("fff").live_grep({ grep = { modes = { "fuzzy", "plain" } } })
    end, { desc = "Live fffuzy grep" })
    vim.keymap.set("n", "fw", function() require("fff").live_grep({ query = vim.fn.expand("<cword>") }) end,
      { desc = "Search current word" })
  end,
}
