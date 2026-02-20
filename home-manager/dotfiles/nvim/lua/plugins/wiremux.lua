--- https://github.com/MSmaili/wiremux-nvim
---
return {
  "MSmaili/wiremux.nvim",
  dependencies = {
    -- Optional: nicer picker UI
    --- "ibhagwan/fzf-lua",
  },
  opts = {
    picker = { adapter = "telescope" },
    targets = {
      definitions = {
        opencode = { cmd = "opencode", kind = "pane", split = "horizontal", shell = false },
        claude = { cmd = "claude", kind = "pane", split = "horizontal", shell = false },
        shell = { kind = "pane", split = "horizontal" },
      },
    },

    -- see Quick Start
  },
}
