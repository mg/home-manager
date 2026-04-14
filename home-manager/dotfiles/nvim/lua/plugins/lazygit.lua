-- https://github.com/kdheepak/lazygit.nvim

return {
	"kdheepak/lazygit.nvim",
	lazy = true,
	cmd = {
		"LazyGit",
		"LazyGitConfig",
		"LazyGitCurrentFile",
		"LazyGitFilter",
		"LazyGitFilterCurrentFile",
	},
	-- optional for floating window border decoration
  -- TODO: plenary
	dependencies = {
		"nvim-lua/plenary.nvim",
	},
	-- setting the keybinding for LazyGit with 'keys' is recommended in
	-- order to load the plugin when the command is run for the first time
	keys = {
		{
			"<leader>gdB",
			function()
				if vim.bo.filetype == "oil" then
					vim.notify("LazyGitFilterCurrentFile: switch to a file buffer first (oil:// paths not supported)", vim.log.levels.WARN)
					return
				end
				vim.cmd("LazyGitFilterCurrentFile")
			end,
			desc = "Current buffer history",
		},
	},
}

