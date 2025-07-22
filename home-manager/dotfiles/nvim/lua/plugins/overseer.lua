-- https://github.com/stevearc/overseer.nvim

vim.keymap.set("n", "<leader>tr", ":OverseerRun<CR>", { desc = "[r]un task" })

return {
	"stevearc/overseer.nvim",
	opts = {
		strategy = {
			"toggleterm",
			direction = "tab",
			auto_scroll = true,
		},
	},
}
