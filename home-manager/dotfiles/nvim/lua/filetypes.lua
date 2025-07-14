local esc = vim.api.nvim_replace_termcodes("<Esc>", true, true, true)

vim.api.nvim_create_augroup("DartMacro", { clear = true })
vim.api.nvim_create_autocmd("FileType", {
	group = "DartMacro",
	pattern = { "dart" },
	callback = function()
		-- vim.fn.setreg("l", "test")
	end,
})
