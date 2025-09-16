return {
	"akinsho/toggleterm.nvim",
	version = "*",
	opts = {--[[ things you want to change go here]]
	},
	config = function()
		require("toggleterm").setup({
			float_opts = {
				border = "rounded",
			},
		})

		local Terminal = require("toggleterm.terminal").Terminal
		local lazygit = Terminal:new({ cmd = "lazygit", hidden = true, direction = "float" })

		function LazygitToggle()
			lazygit:toggle()
		end

		vim.api.nvim_set_keymap("n", "<leader>tt", ":ToggleTerm direction=float<CR>", { noremap = true, silent = true })
	end,
}
