-- https://github.com/emmanueltouzery/elixir-extras.nvim

return {
  "emmanueltouzery/elixir-extras.nvim",
  cond = require("lib").is_elixir_project,
  keys = {
    {
      "<leader>Ed",
      function() require('elixir-extras').elixir_view_docs({ include_mix_libs = true }) end,
      desc = "Show Elixir Docs",
    },
    {
      "<leader>Em",
      function() require('elixir-extras').module_complete() end,
      desc = "Complete [M]odule",
    },
    {
      "<leader>Ea",
      function() require('elixir-extras').module_complete_alias() end,
      desc = "Complete [A]lias",
    },
  },
  config = function()
    require('elixir-extras').setup_multiple_clause_gutter()
    require('which-key').add({ { '<leader>E', group = '[E]lixir' } })
  end,
}
