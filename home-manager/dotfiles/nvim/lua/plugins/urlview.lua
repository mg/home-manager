return {
	"axieax/urlview.nvim",
	config = function()
		require("urlview").setup({
			default_action = "system",
		})
	end,
}
