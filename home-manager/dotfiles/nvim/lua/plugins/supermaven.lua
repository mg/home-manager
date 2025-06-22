vim.g.SUPERMAVEN_DISABLED = true

return {
	"supermaven-inc/supermaven-nvim",
	config = function()
		require("supermaven-nvim").setup({
			keymaps = {
				accept_suggestion = "<C-]>",
				clear_suggestion = "<C-c>",
			},
			disable_inline_completion = true,
			condition = function()
				return vim.g.SUPERMAVEN_DISABLED
			end,
		})
	end,
}
