-- https://github.com/dmtrKovalenko/fold-imports.nvim

return {
	"dmtrKovalenko/fold-imports.nvim",
	opts = {},
	event = "BufRead",
	config = function()
		require("fold_imports").setup({
			languages = {
				dart = {
					enabled = true,
					parsers = { "dart" },
					queries = {
						"(import_or_export) @import",
					},
					filetypes = { "dart" },
					patterns = { "*.dart" },
				},
			},
		})
	end,
}
