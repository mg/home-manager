-- https://github.com/Rics-Dev/project-explorer.nvim

return {
	"Rics-Dev/project-explorer.nvim",
	dependencies = {
		"nvim-telescope/telescope.nvim",
	},
	opts = {
		paths = { "~/Work", "~/Projects" }, -- Custom paths
		file_explorer = function(dir) -- default is netrw
			vim.cmd("Neotree close")
			vim.cmd("Neotree " .. dir)
		end,
	},
	config = function(_, opts)
		require("project_explorer").setup(opts)
	end,
	keys = {
		{ "<leader>sp", "<cmd>ProjectExplorer<cr>", desc = "Project Explorer" },
	},
	--Ensure the plugin is loaded correctly
	lazy = false,
}
