-- https://github.com/nvim-lualine/lualine.nvim?tab=readme-ov-file

return {
	"nvim-lualine/lualine.nvim",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	config = function()
		require("lualine").setup({
			options = {
				globalstatus = true,
			},
			sections = {
				lualine_a = {
					"mode",
				},
				lualine_c = {
					{
						"filename",
						path = 1,
					},
				},
			},
		})
	end,
}
