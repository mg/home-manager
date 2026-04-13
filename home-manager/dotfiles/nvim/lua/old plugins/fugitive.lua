-- https://github.com/tpope/vim-fugitive

return {
	"tpope/vim-fugitive",
	dependencies = {
		"tpope/vim-rhubarb", -- GitHub support for fugitive
	},
	config = function()
		-- Configure for GitHub Enterprise
		vim.g.github_enterprise_urls = { "https://git.lais.net" }
	end,
	keys = {
		{ "<leader>hy", ":GBrowse!<cr>", desc = "Copy git permalink" },
	},
}
