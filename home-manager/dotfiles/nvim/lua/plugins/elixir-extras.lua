-- https://github.com/emmanueltouzery/elixir-extras.nvim
return {
	"emmanueltouzery/elixir-extras.nvim",
	keys = {
		{
			"<Leader>do",
			":lua require('elixir-extras').elixir_view_docs({include_mix_libs=true})<cr>",
			{ silent = true, noremap = true, desc = "Show Elixir Docs" },
		},
	},
	config = function()
		vim.cmd([[
    :lua require'elixir-extras'.setup_multiple_clause_gutter()
  ]])
	end,
}
