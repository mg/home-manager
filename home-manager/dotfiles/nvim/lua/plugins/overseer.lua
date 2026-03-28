-- https://github.com/stevearc/overseer.nvim

vim.keymap.set("n", "<leader>tr", ":OverseerRun<CR>", { desc = "[r]un task" })

return {
	"stevearc/overseer.nvim",
	opts = {
		component_aliases = {
			default = {
				"on_exit_set_status",
				"on_complete_notify",
				{ "on_complete_dispose", require_view = { "SUCCESS", "FAILURE" } },
				{ "open_output", on_start = "always", direction = "tab", focus = true },
			},
		},
	},
	config = function(_, opts)
		require("overseer").setup(opts)
		-- Enter terminal mode when overseer opens task output
		vim.api.nvim_create_autocmd("BufWinEnter", {
			callback = function(args)
				if vim.bo[args.buf].buftype == "terminal" then
					vim.schedule(function()
						if vim.api.nvim_get_current_buf() == args.buf then
							vim.cmd("startinsert")
						end
					end)
				end
			end,
		})
	end,
}
