return {
	"axieax/urlview.nvim",
	event = "BufRead",
	config = function()
		require("urlview").setup({
			default_action = "system",
		})
	end,
}
