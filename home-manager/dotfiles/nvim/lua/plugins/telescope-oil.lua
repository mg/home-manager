-- https://github.com/albenisolmos/telescope-oil.nvim

vim.keymap.set("n", "<leader>sl", "<cmd>Telescope oil<CR>", { noremap = true, silent = true })

return {
	"albenisolmos/telescope-oil.nvim",
	config = function()
		-- optionally override defaults
		local settings = require("telescope-oil.settings")
		settings.set({ hidden = false })
		settings.set({ no_ignore = false })
		settings.set({ show_preview = true })
		-- load extension
		require("telescope").load_extension("oil")
	end,
}
