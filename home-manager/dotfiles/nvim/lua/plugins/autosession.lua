return {
	"rmagatti/auto-session",
	config = function()
		require("auto-session").setup({
			log_level = "error",
			auto_session_suppress_dirs = {
				"~/",
				"~/Downloads/*",
				"~/Documents/*",
				"~/Local Documents/*",
			},
			--[[	
			auto_session_allowed_dirs = { 
				"~/Projects/*",
				"~/Work/*",
			},
			]]
			--
			auto_session_use_git_branch = true,
		})
		vim.o.sessionoptions = "blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,localoptions"
	end,
}
