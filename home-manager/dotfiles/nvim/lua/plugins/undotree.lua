return {
	"mbbill/undotree",
	config = function()
		vim.keymap.set("n", "<leader>ut", function()
			vim.cmd.UndotreeToggle()
			vim.cmd.UndotreeFocus()
		end, { desc = "[U]ndo [T]ree" })
	end,
}
