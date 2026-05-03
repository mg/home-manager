return {
  src = "file:///Users/mg/Projects/pi-sessions/pi-session.nvim",
  config = function()
    require("pi_session").setup({
      sessions_dir = "~/.pi/agent/sessions",
      viewer = {
        open_cmd = "tabnew",
      }
    })
  end,
}
