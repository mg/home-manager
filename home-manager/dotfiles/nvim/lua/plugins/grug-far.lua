-- https://github.com/MagicDuck/grug-far.nvim

return {
  'MagicDuck/grug-far.nvim',
  -- Note (lazy loading): grug-far.lua defers all it's requires so it's lazy by default
  -- additional lazy config to defer loading is not really needed...
  config = function()
    -- optional setup call to override plugin options
    -- alternatively you can set options with vim.g.grug_far = { ... }
    require('grug-far').setup({
      -- options, see Configuration section below
      -- there are no required options atm
    });
  end,
  keys = {
    { "<leader>sgw", "<cmd>lua require('grug-far').open({ prefills = { search = vim.fn.expand('<cword>') } })<CR>",                     desc = "Grug word" },
    { "<leader>sga", "<cmd>lua require('grug-far').open({ engine = 'astgrep', prefills = { search = vim.fn.expand('<cword>') } })<CR>", desc = "Grug ast-grep word" },
  },
}
