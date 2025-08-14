-- https://github.com/dlants/magenta.nvim

return {
	"dlants/magenta.nvim",
	lazy = false, -- you could also bind to <leader>mt
	build = "node install --frozen-lockfile",
	opts = {},
	setup = function()
		require("magenta").setup({
			-- {
			-- 	name = "claude-max",
			-- 	provider = "anthropic",
			-- 	model = "claude-4-sonnet-latest",
			-- 	fastModel = "claude-3-5-haiku-latest",
			-- 	authType = "max", -- Use Anthropic OAuth instead of API key
			-- },
			{
				name = "copilot",
				provider = "copilot",
				model = "gpt-5",
				fastModel = "claude-sonnet-4", -- optional, defaults provided
				-- No apiKeyEnvVar needed - uses existing Copilot authentication
			},
			picker = "telescope",
			sidebarPosition = "right",
			sidebarKeys = {
				normal = {
					["<CR"] = ":Magenta send<CR>",
				},
			},
			inlineKeymaps = {
				normal = {
					["<CR>"] = function(target_bufnr)
						vim.cmd("Magenta submit-inline-edit " .. target_bufnr)
					end,
				},
			},
			editPrediction = {
				changeTrackerMaxChanges = 20,
				recentChangeTokenBudget = 1500,
				systemPromptAppend = "Focus on completing function calls and variable declarations.",
			},
			maxConcurrentSubagents = 3,
			mcpServers = {
				mcphub = {
					url = "http://localhost:37373/mcp",
				},
			},
		})
	end,
}
