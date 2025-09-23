vim.api.nvim_create_autocmd("User", {
	pattern = "CopilotAuth",
	callback = function()
		-- Silently handle auth errors
		pcall(function()
			vim.cmd("Copilot auth")
		end)
	end,
})

return {
	"zbirenbaum/copilot.lua",
	event = "InsertEnter",
	config = function()
		require("copilot").setup({
			suggestion = { enabled = true },
			panel = { enabled = true },
		})
	end,
}
