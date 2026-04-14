return {
  src = "https://github.com/folke/snacks.nvim",
  config = function()
    require("snacks").setup({
      notifier = { enabled = true, timeout = 5000 },
      picker = {
        enabled = true,
        actions = setmetatable({}, {
          __index = function(_, key)
            return require("trouble.sources.snacks").actions[key]
          end,
        }),
        win = {
          input = {
            keys = {
              ["<c-t>"] = { "trouble_open", mode = { "n", "i" } },
            },
          },
        },
      },
      indent = { enabled = true, animate = { enabled = false }, },
      image = { enabled = true },
      explorer = { enabled = false },
      bigfile = { enabled = true },
      lazygit = { enabled = true },
    })
    -- Replace vim.notify with snacks notifier
    vim.notify = require("snacks").notifier.notify
  end,
  keys = {
    { "<leader><space>", function() Snacks.picker.buffers() end,         desc = "Buffers" },
    { "<leader>:",       function() Snacks.picker.command_history() end, desc = "Command History" },
    { "<leader>n",       function() Snacks.picker.notifications() end,   desc = "Notification History" },
    { "<leader>e",       function() vim.cmd("Oil") end,                  desc = "File Explorer" },
    { "<leader>gf",      function() Snacks.picker.git_files() end,       desc = "Git Files" },
    {
      "<leader>fo",
      function()
        local dirs = vim.fn.systemlist({ "fd", "--type", "d", "--color", "never", "-E", ".git" })
        local items = {}
        for _, d in ipairs(dirs) do
          table.insert(items, { text = d, file = d })
        end
        Snacks.picker({
          title = "Open folder in Oil",
          items = items,
          confirm = function(picker, item)
            picker:close()
            if item then
              vim.cmd("Oil " .. vim.fn.fnameescape(item.text))
            end
          end,
        })
      end,
      desc = "Find folder → Open in Oil"
    },

    -- lazygit
    { "<leader>gg", function() Snacks.lazygit() end,                       desc = "LazyGit" },
    { "<leader>gB", function() Snacks.git.blame_line() end,                desc = "Git Blame Line" },

    -- git
    { "<leader>gb", function() Snacks.picker.git_branches() end,           desc = "Git Branches" },
    { "<leader>gll", function() Snacks.picker.git_log() end,               desc = "Git Log" },
    { "<leader>glL", function() Snacks.picker.git_log_line() end,           desc = "Git Log Line" },
    { "<leader>glf", function() Snacks.picker.git_log_file() end,           desc = "Git Log File" },
    { "<leader>gs", function() Snacks.picker.git_status() end,             desc = "Git Status" },
    { "<leader>gS", function() Snacks.picker.git_stash() end,              desc = "Git Stash" },
    { "<leader>gdh", function() Snacks.picker.git_diff() end,              desc = "Git Diff (Hunks)" },

    -- gh
    { "<leader>gp", function() Snacks.picker.gh_pr() end,                  desc = "GitHub Pull Requests (open)" },
    { "<leader>gP", function() Snacks.picker.gh_pr({ state = "all" }) end, desc = "GitHub Pull Requests (all)" },

    -- search
    { '<leader>s"', function() Snacks.picker.registers() end,              desc = "Registers" },
    { '<leader>s/', function() Snacks.picker.search_history() end,         desc = "Search History" },
    { "<leader>sa", function() Snacks.picker.autocmds() end,               desc = "Autocmds" },
    { "<leader>sb", function() Snacks.picker.lines() end,                  desc = "Buffer Lines" },
    { "<leader>sc", function() Snacks.picker.command_history() end,        desc = "Command History" },
    { "<leader>sC", function() Snacks.picker.commands() end,               desc = "Commands" },
    { "<leader>sd", function() Snacks.picker.diagnostics() end,            desc = "Diagnostics" },
    { "<leader>sD", function() Snacks.picker.diagnostics_buffer() end,     desc = "Buffer Diagnostics" },
    { "<leader>sh", function() Snacks.picker.help() end,                   desc = "Help Pages" },
    { "<leader>sH", function() Snacks.picker.highlights() end,             desc = "Highlights" },
    { "<leader>sj", function() Snacks.picker.jumps() end,                  desc = "Jumps" },
    { "<leader>sk", function() Snacks.picker.keymaps() end,                desc = "Keymaps" },
    { "<leader>sl", function() Snacks.picker.loclist() end,                desc = "Location List" },
    { "<leader>sm", function() Snacks.picker.marks() end,                  desc = "Marks" },
    { "<leader>sq", function() Snacks.picker.qflist() end,                 desc = "Quickfix List" },
    { "<leader>sR", function() Snacks.picker.resume() end,                 desc = "Resume" },
    { "<leader>su", function() Snacks.picker.undo() end,                   desc = "Undo History" },
    { "<leader>sw", function() Snacks.picker.grep_word() end,              desc = "Search Word under cursor" },

    -- LSP
    { "gd",         function() Snacks.picker.lsp_definitions() end,        desc = "Goto Definition" },
    { "gD",         function() Snacks.picker.lsp_declarations() end,       desc = "Goto Declaration" },
    { "grr",        function() Snacks.picker.lsp_references() end,         desc = "References" },
    { "gI",         function() Snacks.picker.lsp_implementations() end,    desc = "Goto Implementation" },
    { "gy",         function() Snacks.picker.lsp_type_definitions() end,   desc = "Goto T[y]pe Definition" },
    { "gai",        function() Snacks.picker.lsp_incoming_calls() end,     desc = "C[a]lls Incoming" },
    { "gao",        function() Snacks.picker.lsp_outgoing_calls() end,     desc = "C[a]lls Outgoing" },
    { "<leader>ss", function() Snacks.picker.lsp_symbols() end,            desc = "LSP Symbols" },
    { "<leader>sS", function() Snacks.picker.lsp_workspace_symbols() end,  desc = "LSP Workspace Symbols" },

  }
}
