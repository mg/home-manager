-- nvim --headless -u NONE -l tests/zig_tools.lua (from the Neovim config dir)
local config_dir = vim.fn.getcwd()
vim.opt.runtimepath:prepend(config_dir)
local original_system, original_exepath, original_notify = vim.system, vim.fn.exepath, vim.notify
local original_lang, original_zig, original_zls =
  vim.env.DEVC_LANG, vim.env.ZIG_PATH, vim.env.ZLS_PATH
local calls, notifications = {}, {}
local running, guest_tools, host_tools = false, {}, {}
local root = "/tmp/zig project"
vim.fn.exepath = function(tool)
  if tool == "fish" or tool == "container" then
    return "/bin/" .. tool
  end
  return host_tools[tool] or ""
end
-- executable() still checks the real machine; replace it for deterministic tests.
local original_executable = vim.fn.executable
vim.fn.executable = function(tool)
  return vim.fn.exepath(tool) ~= "" and 1 or 0
end
vim.notify = function(message)
  notifications[#notifications + 1] = message
end
vim.system = function(cmd, opts, callback)
  calls[#calls + 1] = { cmd = vim.deepcopy(cmd), opts = opts }
  local stdout = ""
  local code = 0
  if cmd[1] == "fish" then
    assert(cmd[3] == "devc name", "must not invoke devc run/start during detection")
    stdout = "dev-zig-project\n"
  elseif cmd[1] == "container" and cmd[2] == "ls" then
    stdout = running and "dev-zig-project\n" or ""
  elseif cmd[1] == "container" and cmd[4] == "sh" then
    local tool = cmd[6]:match("'([^']+)'$")
    stdout = guest_tools[tool] and "/usr/bin/" .. tool or ""
    code = guest_tools[tool] and 0 or 1
  end
  local result = { code = code, stdout = stdout, stderr = "" }
  if callback then
    callback(result)
  end
  return {
    wait = function()
      return result
    end,
  }
end

local ok, err = xpcall(function()
  local tools = require("zig-tools")
  vim.env.DEVC_LANG, vim.env.ZIG_PATH, vim.env.ZLS_PATH = nil, nil, nil
  host_tools = { zig = "/host/zig", zls = "/host/zls" }
  assert(
    vim.deep_equal(
      tools.command({ "zig", "test", "file with spaces.zig" }, root),
      { "/host/zig", "test", "file with spaces.zig" }
    )
  )
  assert(#calls == 0, "normal host projects must not probe containers")

  vim.env.DEVC_LANG = "zig"
  assert(tools.command({ "zig", "build" }, root)[1] == "/host/zig", "stopped container fallback")
  running, guest_tools = true, { zig = true, zls = true, ["lldb-dap"] = true }
  assert(vim.deep_equal(tools.command({ "zig", "run", "file with spaces.zig" }, root), {
    "container",
    "exec",
    "-i",
    "-w",
    root,
    "dev-zig-project",
    "zig",
    "run",
    "file with spaces.zig",
  }))
  vim.env.DEVC_LANG = "local"
  assert(tools.command({ "zig", "build" }, root)[1] == "container", "custom images supported")
  guest_tools.zig = nil
  assert(tools.command({ "zig", "build" }, root)[1] == "/host/zig", "missing guest tool fallback")
  guest_tools.zig = true

  host_tools["/custom/zig"] = "/custom/zig"
  vim.env.ZIG_PATH = "/custom/zig"
  calls = {}
  assert(tools.command({ "zig", "build" }, root)[1] == "/custom/zig")
  assert(#calls == 0, "explicit override must bypass detection")
  vim.env.ZIG_PATH = "/missing/zig"
  assert(
    tools.command({ "zig", "build" }, root) == nil,
    "invalid override must not silently switch"
  )
  vim.env.ZIG_PATH = ""
  assert(tools.command({ "zig", "build" }, root)[1] == "container", "empty override ignored")

  running, host_tools = false, {}
  assert(tools.command({ "zig", "build" }, root) == nil, "missing tools handled")
  tools.run({ "zig", "build" }, root, function()
    error("must not run")
  end)
  assert(#notifications == 1 and notifications[1]:find("no host zig", 1, true))
  host_tools = { zig = "/host/zig", zls = "/host/zls" }
  local saved_system = vim.system
  vim.env.DEVC_LANG = nil
  vim.system = function()
    error("spawn failed")
  end
  tools.run({ "zig", "build" }, root, function() end)
  assert(notifications[#notifications]:find("could not launch", 1, true))
  vim.system = saved_system

  -- Check ZLS config arguments, host cwd and supervisor selection.
  local rpc_start = vim.lsp.rpc.start
  local launched
  vim.lsp.rpc.start = function(cmd, _, opts)
    launched = { cmd = cmd, opts = opts }
    return launched
  end
  local zls = dofile(config_dir .. "/lsp/zls.lua")
  local tmp = vim.fn.tempname()
  vim.fn.mkdir(tmp, "p")
  vim.fn.writefile({ "{}" }, tmp .. "/zls.json")
  zls.cmd({}, { root_dir = tmp })
  assert(vim.deep_equal(launched.cmd, { "/host/zls", "--config-path", tmp .. "/zls.json" }))
  assert(launched.opts.cwd == tmp)
  vim.env.DEVC_LANG, running = "zig", true
  zls.cmd({}, { root_dir = tmp })
  assert(launched.cmd[1] == vim.v.progpath and launched.cmd[2] == "-l")
  assert(launched.cmd[4] == "zls" and launched.cmd[6] == tmp .. "/zls.json")
  vim.env.ZIG_PATH = "/host/zig"
  zls.cmd({}, { root_dir = tmp })
  assert(launched.cmd[1] == "/host/zls", "host compiler override keeps ZLS on host")
  vim.env.ZLS_PATH = "/host/zls"
  host_tools["/host/zls"] = "/host/zls"
  zls.cmd({}, { root_dir = tmp })
  assert(launched.cmd[1] == "/host/zls")
  vim.lsp.rpc.start = rpc_start
  vim.fn.delete(tmp, "rf")

  -- All file commands use the resolver (including nearest-test dispatch).
  local file = vim.fn.tempname() .. ".zig"
  vim.fn.writefile({ 'test "example" {}' }, file)
  vim.cmd.edit(file)
  file = vim.api.nvim_buf_get_name(0)
  local run_count, nearest = 0, false
  tools.run = function(command, cwd)
    run_count = run_count + 1
    assert(
      command[1] == "zig"
        and cwd
          == (vim.fs.root(file, { "build.zig", "zls.json", ".git" }) or vim.fs.dirname(file)),
      vim.inspect({ command = command, cwd = cwd, file = file })
    )
    if command[5] == "--test-filter" then
      nearest = true
    end
  end
  local original_parser = vim.treesitter.get_parser
  local original_text = vim.treesitter.get_node_text
  local node = {
    type = function()
      return "test_declaration"
    end,
  }
  node.iter_children = function()
    local done = false
    return function()
      if not done then
        done = true
        return {
          type = function()
            return "string"
          end,
        }
      end
    end
  end
  vim.treesitter.get_parser = function()
    return {
      parse = function()
        return {
          {
            root = function()
              return {
                named_descendant_for_range = function()
                  return node
                end,
              }
            end,
          },
        }
      end,
    }
  end
  vim.treesitter.get_node_text = function()
    return '"example"'
  end
  dofile(config_dir .. "/ftplugin/zig.lua")
  for _, command in ipairs({ "ZigBuild", "ZigRun", "ZigTestFile", "ZigTestNearest" }) do
    vim.cmd(command)
  end
  assert(run_count == 4 and nearest, "all Zig commands must resolve at execution time")
  vim.treesitter.get_parser, vim.treesitter.get_node_text = original_parser, original_text
  vim.fn.delete(file)
  -- Load DAP configuration with lightweight plugin stubs and exercise selection.
  local dap = {
    adapters = {},
    configurations = {},
    listeners = {
      after = { event_initialized = {} },
      before = { event_terminated = {}, event_exited = {} },
    },
  }
  package.loaded.dap = dap
  package.loaded.dapui = { setup = function() end }
  package.loaded["nvim-dap-virtual-text"] = { setup = function() end }
  package.loaded["dap-vscode-js"] = { setup = function() end }
  package.loaded["dap.utils"] = { pick_process = function() end }
  vim.env.DEVC_LANG, vim.env.ZIG_PATH, vim.env.ZLS_PATH = "zig", nil, nil
  running = true
  dofile(config_dir .. "/lua/plugins/dap.lua").config()
  local adapter
  local function launch()
    dap.adapters.lldb(function(value)
      adapter = value
    end, { cwd = root })
  end
  launch()
  assert(adapter.command == "container" and adapter.args[6] == "lldb-dap")
  adapter = nil
  guest_tools["lldb-dap"] = nil
  launch()
  assert(adapter == nil and notifications[#notifications]:find("refusing", 1, true))
  running = false
  host_tools["lldb-dap"] = "/host/lldb-dap"
  host_tools["xcrun"] = nil
  launch()
  assert(adapter.command == "/host/lldb-dap")
  running = true
  vim.env.ZIG_PATH = "/host/zig"
  host_tools["/host/zig"] = "/host/zig"
  launch()
  assert(adapter.command == "/host/lldb-dap", "host compiler override requires host debugger")
end, debug.traceback)
vim.system, vim.fn.exepath, vim.fn.executable, vim.notify =
  original_system, original_exepath, original_executable, original_notify
vim.env.DEVC_LANG, vim.env.ZIG_PATH, vim.env.ZLS_PATH = original_lang, original_zig, original_zls
if not ok then
  io.stderr:write(err .. "\n")
  vim.cmd("cquit 1")
end
print(
  "PASS: Zig container/host resolution, overrides, missing tools, ZLS and build/run/test commands"
)
vim.cmd("messages")
vim.cmd("qa!")
