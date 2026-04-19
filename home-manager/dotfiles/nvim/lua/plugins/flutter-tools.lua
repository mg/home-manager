return {
  "akinsho/flutter-tools.nvim",
  lazy = true,
  ft = { "dart" },
  dependencies = {
    "mfussenegger/nvim-dap",
    "nvim-lua/plenary.nvim",
    "stevearc/dressing.nvim",
  },
  keys = {
    {
      "<leader>F",
      function()
        local commands = {
          { name = "FlutterRun",              desc = "Run the current project" },
          { name = "FlutterDebug",            desc = "Force run in debug mode" },
          { name = "FlutterDevices",          desc = "List connected devices" },
          { name = "FlutterEmulators",        desc = "List emulators" },
          { name = "FlutterReload",           desc = "Reload the running project" },
          { name = "FlutterRestart",          desc = "Restart the current project" },
          { name = "FlutterQuit",             desc = "End running session" },
          { name = "FlutterAttach",           desc = "Attach to a running app" },
          { name = "FlutterDetach",           desc = "Detach but keep process running" },
          { name = "FlutterOutlineToggle",    desc = "Toggle widget tree outline" },
          { name = "FlutterOutlineOpen",      desc = "Open widget tree outline" },
          { name = "FlutterDevTools",         desc = "Start Dart Dev Tools server" },
          { name = "FlutterDevToolsActivate",  desc = "Activate Dart Dev Tools server" },
          { name = "FlutterCopyProfilerUrl",  desc = "Copy profiler URL to clipboard" },
          { name = "FlutterLspRestart",       desc = "Restart Dart language server" },
          { name = "FlutterSuper",            desc = "Go to super class/method" },
          { name = "FlutterReanalyze",        desc = "Force LSP reanalyze" },
          { name = "FlutterRename",           desc = "Rename and update imports" },
          { name = "FlutterLogClear",         desc = "Clear log buffer" },
          { name = "FlutterLogToggle",        desc = "Toggle log buffer" },
        }

        Snacks.picker({
          title = "Flutter",
          items = vim.tbl_map(function(cmd)
            return { text = cmd.name .. " - " .. cmd.desc, cmd = cmd.name }
          end, commands),
          format = function(item)
            return { { item.text } }
          end,
          confirm = function(picker, item)
            picker:close()
            vim.cmd(item.cmd)
          end,
        })
      end,
      desc = "Flutter commands",
    },
  },
  config = function()
    require("flutter-tools").setup({
      debugger = {
        enabled = true,
      },
      lsp = {
        color = {
          enabled = true,
        },
      },
      dev_tools = {
        autostart = false,
        auto_open_browser = false,
      },
      outline = {
        open_cmd = "30vnew",
        auto_open = false,
      },
    })
  end,
}
