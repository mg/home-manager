-- https://github.com/cousine/opencode-context.nvim

return {
	"cousine/opencode-context.nvim",
	opts = {
		tmux_target = "Opencode", -- Manual override: "session:window.pane"
		auto_detect_pane = true, -- Auto-detect opencode pane in current window
	},
	keys = {
		{ "<leader>oc", "<cmd>OpencodeSend<cr>", desc = "Send prompt to opencode" },
		{ "<leader>oc", "<cmd>OpencodeSend<cr>", mode = "v", desc = "Send prompt to opencode" },
		{ "<leader>ot", "<cmd>OpencodeSwitchMode<cr>", desc = "Toggle opencode mode" },
		{ "<leader>op", "<cmd>OpencodePrompt<cr>", desc = "Open opencode persistent prompt" },
	},
	cmd = { "OpencodeSend", "OpencodeSwitchMode" },
}
