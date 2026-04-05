return {
  "dmtrKovalenko/fff.nvim",
  tag = "v0.5.2",
  build = "curl -sL https://github.com/dmtrKovalenko/fff.nvim/releases/download/v0.5.2/aarch64-apple-darwin.dylib -o target/release/libfff_nvim.dylib",
  opts = { -- (optional)
    debug = {
      enabled = true, -- we expect your collaboration at least during the beta
      show_scores = true, -- to help us optimize the scoring system, feel free to share your scores!
    },
  },
  -- No need to lazy-load with lazy.nvim.
  -- This plugin initializes itself lazily.
  lazy = false,
  keys = {
    {
      "ff", -- try it if you didn't it is a banger keybinding for a picker
      function()
        require("fff").find_files()
      end,
      desc = "FFFind files",
    },
    {
      "fg",
      function()
        require("fff").live_grep()
      end,
      desc = "LiFFFe grep",
    },
    {
      "fz",
      function()
        require("fff").live_grep({
          grep = {
            modes = { "fuzzy", "plain" },
          },
        })
      end,
      desc = "Live fffuzy grep",
    },
  },
}
