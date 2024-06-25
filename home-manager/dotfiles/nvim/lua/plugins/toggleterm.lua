local Terminal = require("toggleterm.terminal").Terminal
local lazygit = Terminal:new({ cmd = "lazygit", hidden = true })

function LazygitToggle()
	lazygit:toggle()
end

vim.api.nvim_set_keymap("n", "<leader>gl", "<cmd>lua LazygitToggle()<CR>", { noremap = true, silent = true })

return {
	"akinsho/toggleterm.nvim",
	version = "*",
	opts = {--[[ things you want to change go here]]
	},
}
