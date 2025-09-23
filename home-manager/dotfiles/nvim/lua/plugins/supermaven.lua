return {
	"supermaven-inc/supermaven-nvim",
	event = "BufRead",
	config = function()
		require("supermaven-nvim").setup({
			keymaps = {
				accept_suggestion = "<C-]>",
				clear_suggestion = "<C-c>",
			},
			disable_inline_completion = true,
		})
	end,
}
