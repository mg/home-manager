-- DAP setup for the languages/debug targets used in this config.
--
-- Common flow:
--   1. Open a file for the language you want to debug
--   2. Set a breakpoint with <leader>db or <F9>
--   3. Start/continue with <leader>dc or <F6>
--   4. Step with <leader>di/<leader>do/<leader>du or F11/F10/F12
--   5. Toggle dap-ui with <leader>dw and REPL with <leader>dr
--
-- Supported here:
--   - JavaScript / TypeScript
--   - Python
--   - Lua running inside Neovim (config/plugins)
--   - Dart / Flutter
--   - Zig via LLDB
--
-- Project-specific configs via .vscode/launch.json
--   - nvim-dap loads .vscode/launch.json automatically so project configs are shown
--     alongside the global configs defined below
--   - Use :DapOpenLaunchJson to open/create the project file
--   - Use adapter types that match this config: pwa-node, pwa-chrome, python, dart, lldb
--   - Keep launch.json as strict JSON here (no trailing commas)
--
-- Example launch.json:
--   {
--     "version": "0.2.0",
--     "configurations": [
--       {
--         "type": "pwa-chrome",
--         "request": "launch",
--         "name": "Frontend",
--         "url": "http://localhost:5173",
--         "webRoot": "${workspaceFolder}"
--       }
--     ]
--   }
--
-- Elixir DAP is intentionally not configured for now.
local function ensure_mason_packages(packages)
  local ok, registry = pcall(require, "mason-registry")
  if not ok then
    return
  end

  registry.refresh(function(success)
    if not success then
      return
    end

    for _, package_name in ipairs(packages) do
      if registry.has_package(package_name) then
        local package = registry.get_package(package_name)
        if not package:is_installed() and not package:is_installing() then
          package:install()
        end
      end
    end
  end)
end

local function python_path()
  local sep = vim.fn.has("win32") == 1 and "\\" or "/"
  local workspace = vim.fn.getcwd()
  local environments = {
    os.getenv("VIRTUAL_ENV"),
    os.getenv("CONDA_PREFIX"),
    workspace .. sep .. ".venv",
    workspace .. sep .. "venv",
  }

  for _, env in ipairs(environments) do
    if env and env ~= "" then
      local python = vim.fn.has("win32") == 1 and (env .. "\\Scripts\\python")
        or (env .. "/bin/python")
      if vim.fn.executable(python) == 1 then
        return python
      end
    end
  end

  local python3 = vim.fn.exepath("python3")
  if python3 ~= "" then
    return python3
  end

  local python = vim.fn.exepath("python")
  if python ~= "" then
    return python
  end

  return "python3"
end

local function dart_paths()
  local flutter_bin = vim.fn.resolve(vim.fn.exepath("flutter"))
  local dart_bin = vim.fn.resolve(vim.fn.exepath("dart"))

  if flutter_bin == "" and dart_bin == "" then
    return nil
  end

  local flutter_sdk = ""
  local dart_sdk = ""

  if flutter_bin ~= "" then
    flutter_sdk = vim.fn.fnamemodify(flutter_bin, ":h:h")
    dart_sdk = flutter_sdk .. "/bin/cache/dart-sdk"
    if dart_bin == "" then
      dart_bin = dart_sdk .. "/bin/dart"
    end
  elseif dart_bin ~= "" then
    dart_sdk = vim.fn.fnamemodify(dart_bin, ":h:h")
  end

  return {
    flutter_bin = flutter_bin,
    flutter_sdk = flutter_sdk,
    dart_bin = dart_bin,
    dart_sdk = dart_sdk,
  }
end

local function flutter_entrypoint()
  local root = vim.fs.root(0, "pubspec.yaml")
  if root then
    local main = vim.fs.joinpath(root, "lib", "main.dart")
    if vim.fn.filereadable(main) == 1 then
      return main
    end
  end

  return vim.api.nvim_buf_get_name(0)
end

local function dart_entrypoint()
  local root = vim.fs.root(0, "pubspec.yaml")
  if root then
    local bin_main = vim.fs.joinpath(root, "bin", vim.fn.fnamemodify(root, ":t") .. ".dart")
    if vim.fn.filereadable(bin_main) == 1 then
      return bin_main
    end
  end

  return vim.api.nvim_buf_get_name(0)
end

local nlua_port = 8086

local function project_launch_json_path()
  return vim.fs.joinpath(vim.fn.getcwd(), ".vscode", "launch.json")
end

local function chrome_url()
  local default_url = "http://localhost:3000"
  local url = vim.fn.input("Chrome URL: ", default_url)
  if url == "" then
    return default_url
  end

  return url
end

local function lldb_dap_path()
  local from_env = vim.env.LLDB_DAP_PATH
  if from_env and from_env ~= "" and vim.fn.executable(from_env) == 1 then
    return from_env
  end

  local from_path = vim.fn.exepath("lldb-dap")
  if from_path ~= "" then
    return from_path
  end

  for _, path in ipairs({
    "/Library/Developer/CommandLineTools/usr/bin/lldb-dap",
    "/Applications/Xcode.app/Contents/Developer/usr/bin/lldb-dap",
  }) do
    if vim.fn.executable(path) == 1 then
      return path
    end
  end

  return nil
end

return {
  "mfussenegger/nvim-dap",
  dependencies = {
    "nvim-neotest/nvim-nio",
    "rcarriga/nvim-dap-ui",
    "theHamsta/nvim-dap-virtual-text",
    "mxsdev/nvim-dap-vscode-js",
    "jbyuki/one-small-step-for-vimkind",
  },
  cmd = {
    "DapContinue",
    "DapStepInto",
    "DapStepOut",
    "DapStepOver",
    "DapTerminate",
    "DapToggleBreakpoint",
    "DapClearBreakpoints",
    "DapNew",
    "DapInstallAdapters",
    "DapOpenLaunchJson",
  },
  keys = {
    {
      "<leader>dc",
      function()
        require("dap").continue()
      end,
      desc = "[D]ebug [C]ontinue",
    },
    {
      "<leader>db",
      function()
        require("dap").toggle_breakpoint()
      end,
      desc = "[D]ebug Toggle [B]reakpoint",
    },
    {
      "<leader>dB",
      function()
        require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: "))
      end,
      desc = "[D]ebug Conditional [B]reakpoint",
    },
    {
      "<leader>da",
      function()
        require("dap").continue({
          type = "nlua",
          request = "attach",
          name = "Debug Neovim config/plugin",
          host = "127.0.0.1",
          port = nlua_port,
        })
      end,
      desc = "[D]ebug [A]ttach Neovim",
    },
    {
      "<leader>dl",
      function()
        require("osv").launch({ port = nlua_port })
      end,
      desc = "[D]ebug [L]aunch Neovim server",
    },
    {
      "<leader>do",
      function()
        require("dap").step_over()
      end,
      desc = "[D]ebug Step [O]ver",
    },
    {
      "<leader>di",
      function()
        require("dap").step_into()
      end,
      desc = "[D]ebug Step [I]nto",
    },
    {
      "<leader>du",
      function()
        require("dap").step_out()
      end,
      desc = "[D]ebug Step O[u]t",
    },
    {
      "<leader>dr",
      function()
        require("dap").repl.toggle()
      end,
      desc = "[D]ebug [R]EPL",
    },
    {
      "<leader>dt",
      function()
        require("dap").terminate()
      end,
      desc = "[D]ebug [T]erminate",
    },
    {
      "<leader>dw",
      function()
        require("dapui").toggle()
      end,
      desc = "[D]ebug Toggle [W]indows",
    },
    {
      "<F6>",
      function()
        require("dap").continue()
      end,
      desc = "Debug Continue",
    },
    {
      "<F9>",
      function()
        require("dap").toggle_breakpoint()
      end,
      desc = "Debug Toggle Breakpoint",
    },
    {
      "<F10>",
      function()
        require("dap").step_over()
      end,
      desc = "Debug Step Over",
    },
    {
      "<F11>",
      function()
        require("dap").step_into()
      end,
      desc = "Debug Step Into",
    },
    {
      "<F12>",
      function()
        require("dap").step_out()
      end,
      desc = "Debug Step Out",
    },
  },
  config = function()
    local dap = require("dap")
    local dapui = require("dapui")

    local mason_packages = {
      "debugpy",
      "js-debug-adapter",
    }

    ensure_mason_packages(mason_packages)

    vim.api.nvim_create_user_command("DapInstallAdapters", function()
      vim.cmd("MasonInstall " .. table.concat(mason_packages, " "))
    end, { desc = "Install DAP adapters used by this config" })

    vim.api.nvim_create_user_command("DapOpenLaunchJson", function()
      local launch_json = project_launch_json_path()
      vim.fn.mkdir(vim.fs.dirname(launch_json), "p")
      vim.cmd("edit " .. vim.fn.fnameescape(launch_json))
    end, { desc = "Open project .vscode/launch.json" })

    vim.fn.sign_define("DapBreakpoint", { text = "", texthl = "DiagnosticError" })
    vim.fn.sign_define("DapBreakpointCondition", { text = "", texthl = "DiagnosticWarn" })
    vim.fn.sign_define("DapLogPoint", { text = ".>", texthl = "DiagnosticInfo" })
    vim.fn.sign_define("DapStopped", { text = "󰁕", texthl = "DiagnosticOk", linehl = "Visual" })

    dapui.setup({
      icons = { expanded = "▾", collapsed = "▸", current_frame = "▸" },
    })

    require("nvim-dap-virtual-text").setup({})

    dap.listeners.after.event_initialized["dapui_config"] = function()
      dapui.open()
    end
    dap.listeners.before.event_terminated["dapui_config"] = function()
      dapui.close()
    end
    dap.listeners.before.event_exited["dapui_config"] = function()
      dapui.close()
    end

    require("dap-vscode-js").setup({
      debugger_cmd = { "js-debug-adapter" },
      adapters = { "pwa-node", "pwa-chrome" },
    })

    -- JavaScript / TypeScript
    -- - "Launch current file": debug the current file with Node
    -- - "Attach to process": pick a running Node process started with --inspect/--inspect-brk
    -- - "Launch Chrome (URL prompt)": debug a frontend app in Chrome, defaulting to http://localhost:3000
    -- Usage: open a JS/TS buffer, set breakpoints, then run <leader>dc and pick a config.
    local js_configurations = {
      {
        type = "pwa-node",
        request = "launch",
        name = "Launch current file",
        program = "${file}",
        cwd = "${workspaceFolder}",
        sourceMaps = true,
        console = "integratedTerminal",
        skipFiles = { "<node_internals>/**" },
      },
      {
        type = "pwa-node",
        request = "attach",
        name = "Attach to process",
        processId = require("dap.utils").pick_process,
        cwd = "${workspaceFolder}",
        sourceMaps = true,
        skipFiles = { "<node_internals>/**" },
      },
      {
        type = "pwa-chrome",
        request = "launch",
        name = "Launch Chrome (URL prompt)",
        url = chrome_url,
        webRoot = "${workspaceFolder}",
        sourceMaps = true,
        userDataDir = false,
      },
    }

    for _, language in ipairs({ "javascript", "javascriptreact", "typescript", "typescriptreact" }) do
      dap.configurations[language] = js_configurations
    end

    -- Python
    -- - "Launch current file": debug the current Python file
    -- - Interpreter resolution prefers VIRTUAL_ENV / CONDA_PREFIX / .venv / venv, then python3/python
    -- Usage: open a Python buffer, set breakpoints, then run <leader>dc.
    dap.adapters.python = {
      type = "executable",
      command = "debugpy-adapter",
    }

    dap.configurations.python = {
      {
        type = "python",
        request = "launch",
        name = "Launch current file",
        program = "${file}",
        cwd = "${workspaceFolder}",
        pythonPath = python_path,
        console = "integratedTerminal",
      },
    }

    -- Lua (Neovim config/plugins only)
    -- This is intentionally Neovim-specific Lua debugging, not standalone lua/luajit script debugging.
    -- Usage:
    --   1. In the Neovim instance you want to debug, run <leader>dl
    --   2. In another Neovim instance, open the Lua file and set breakpoints
    --   3. Run <leader>da (or <leader>dc and choose "Debug Neovim config/plugin")
    dap.adapters.nlua = function(callback, config)
      callback({
        type = "server",
        host = config.host or "127.0.0.1",
        port = config.port or nlua_port,
      })
    end

    dap.configurations.lua = {
      {
        type = "nlua",
        request = "attach",
        name = "Debug Neovim config/plugin",
        host = "127.0.0.1",
        port = nlua_port,
      },
    }

    -- Zig / LLDB
    -- - "Launch Zig executable": prompts for the compiled binary, defaulting to zig-out/bin/<file>
    --   when build.zig exists, otherwise ./<file>
    -- Usage: build with zig build -Doptimize=Debug (or :ZigBuild), set breakpoints, then run <leader>dc.
    local lldb_dap = lldb_dap_path()
    if lldb_dap then
      dap.adapters.lldb = {
        type = "executable",
        command = lldb_dap,
        name = "lldb",
      }

      dap.configurations.zig = {
        {
          type = "lldb",
          request = "launch",
          name = "Launch Zig executable",
          program = function()
            local root = vim.fs.root(0, "build.zig") or vim.fn.getcwd()
            local file = vim.api.nvim_buf_get_name(0)
            local basename = file ~= "" and vim.fn.fnamemodify(file, ":t:r") or "main"
            local default_program = vim.fs.joinpath(root, basename)

            if vim.fn.filereadable(vim.fs.joinpath(root, "build.zig")) == 1 then
              default_program = vim.fs.joinpath(root, "zig-out", "bin", basename)
            end

            return vim.fn.input("Path to executable: ", default_program, "file")
          end,
          cwd = "${workspaceFolder}",
          stopOnEntry = false,
          args = {},
        },
      }
    end

    -- Dart / Flutter
    -- - "Launch Flutter": uses lib/main.dart when a Flutter project/SDK is available
    -- - "Launch Dart": uses bin/<project>.dart when present, otherwise the current buffer
    -- Usage: open a Dart buffer, set breakpoints, then run <leader>dc and pick a config.
    local dart = dart_paths()
    if dart and dart.dart_bin ~= "" then
      dap.adapters.dart = function(callback, config)
        local is_flutter = config.flutterSdkPath ~= nil and config.flutterSdkPath ~= ""
        local adapter = {
          type = "executable",
          command = is_flutter and dart.flutter_bin or dart.dart_bin,
          args = { is_flutter and "debug-adapter" or "debug_adapter" },
        }

        if vim.fn.has("win32") == 1 then
          adapter.options = { detached = false }
        end

        callback(adapter)
      end

      local dart_configurations = {
        {
          type = "dart",
          request = "launch",
          name = "Launch Dart",
          cwd = "${workspaceFolder}",
          dartSdkPath = dart.dart_sdk,
          program = dart_entrypoint,
        },
      }

      if dart.flutter_bin ~= "" and dart.flutter_sdk ~= "" then
        table.insert(dart_configurations, 1, {
          type = "dart",
          request = "launch",
          name = "Launch Flutter",
          cwd = "${workspaceFolder}",
          dartSdkPath = dart.dart_sdk,
          flutterSdkPath = dart.flutter_sdk,
          program = flutter_entrypoint,
        })
      end

      dap.configurations.dart = dart_configurations
    end

  end,
}
