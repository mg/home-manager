return {
	{
		"CopilotC-Nvim/CopilotChat.nvim",
		dependencies = {
			{ "nvim-lua/plenary.nvim", branch = "master" },
		},
		opts = {
			-- See Configuration section for options
			model = "gpt-5", -- AI model to use
			temperature = 0.1, -- Lower = focused, higher = creative
			window = {
				layout = "vertical", -- 'vertical', 'horizontal', 'float'
				width = 0.3, -- 50% of screen width
			},
			auto_insert_mode = true,
			headers = {
				user = "👤 You: ",
				assistant = "🤖 Copilot: ",
				jtool = "🔧 Tool: ",
			},
			separator = "━━",
		},
	},
}
