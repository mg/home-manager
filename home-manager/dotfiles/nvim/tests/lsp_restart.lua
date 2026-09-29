-- Run against a disposable project through NVIM_APPNAME=nvim-homemanager:
-- DEVC_LANG=elixir DEVC_NAME=... DEVC_TEST_FILE=... DEVC_TEST_LSP=expert \
--   nvim --headless '+luafile tests/lsp_restart.lua'
vim.schedule(function()
  local ok, err = xpcall(function()
    local name = assert(vim.env.DEVC_TEST_LSP)
    local disabled = {}
    for server in pairs(vim.lsp._enabled_configs) do
      if server ~= name then
        disabled[#disabled + 1] = server
      end
    end
    vim.lsp.enable(disabled, false)
    vim.cmd.edit(assert(vim.env.DEVC_TEST_FILE))
    local function client_after(old)
      local client
      assert(
        vim.wait(60000, function()
          local clients = vim.lsp.get_clients({ name = name, bufnr = 0 })
          client = clients[1]
          return #clients == 1 and client.id ~= old and client.initialized
        end, 100),
        "client did not initialize after restart: " .. name
      )
      return client
    end
    local function guest_sessions()
      -- Count actual tagged server processes, not the supervisor command line.
      local result = vim
        .system(
          {
            "container",
            "exec",
            vim.env.DEVC_NAME,
            "bash",
            "-c",
            [[
for entry in /proc/[0-9]*/environ; do
  grep -z '^DEVC_LSP_SESSION=' "$entry" 2>/dev/null | tr '\0' '\n'
done | sort -u
]],
          },
          { text = true }
        )
        :wait()
      assert(result.code == 0, result.stderr)
      return vim.split(vim.trim(result.stdout), "\n", { trimempty = true })
    end
    local function expert_beams(stopped)
      if name ~= "expert" then
        return
      end
      local result = vim
        .system(
          { "container", "exec", vim.env.DEVC_NAME, "ps", "-C", "beam.smp", "-o", "args=" },
          { text = true }
        )
        :wait()
      local beams = vim.split(vim.trim(result.stdout), "\n", { trimempty = true })
      if stopped then
        assert(#beams == 0, "Expert server/engine still running: " .. result.stdout)
      else
        local servers = vim.tbl_filter(function(line)
          return line:find("/.burrito/expert_erts", 1, true)
        end, beams)
        assert(#servers == 1, "expected one Expert server: " .. result.stdout)
      end
    end
    local function symbols(client)
      if not client:supports_method("textDocument/documentSymbol") then
        return
      end
      local result
      -- Expert's project engine may still be initializing after LSP initialize.
      assert(
        vim.wait(120000, function()
          result = client:request_sync("textDocument/documentSymbol", {
            textDocument = vim.lsp.util.make_text_document_params(0),
          }, 5000, 0)
          return result and not result.err and result.result and #result.result > 0
        end, 1000),
        vim.inspect(result)
      )
    end
    local client = client_after(nil)
    symbols(client)
    local previous = guest_sessions()
    assert(#previous == 1, vim.inspect(previous))
    for i = 1, 3 do
      local old_id = client.id
      if i == 3 then
        -- Exercise the force-stop path as well as the actual user command.
        client:_restart(true)
      else
        vim.cmd("lsp restart " .. name)
      end
      client = client_after(old_id)
      symbols(client)
      local current = guest_sessions()
      assert(#current == 1 and current[1] ~= previous[1], vim.inspect(current))
      previous = current
      expert_beams(false)
      print(name .. ": restart " .. i .. " has exactly one guest session")
    end
    client:stop(true)
    assert(
      vim.wait(30000, function()
        return vim.lsp.get_client_by_id(client.id) == nil
      end, 100),
      "stop timeout"
    )
    assert(#guest_sessions() == 0, "guest leaked after host process exited")
    expert_beams(true)
    vim.wait(500, function()
      return false
    end)
    local history = Snacks.notifier.get_history()
    print("MESSAGES:\n" .. vim.api.nvim_exec2("messages", { output = true }).output)
    print("NOTIFIER:\n" .. vim.inspect(history))
    for _, message in ipairs(history) do
      assert(message.level ~= "error" and message.level ~= "warn", message.msg)
    end
  end, debug.traceback)
  if not ok then
    io.stderr:write(err .. "\n")
    print("MESSAGES:\n" .. vim.api.nvim_exec2("messages", { output = true }).output)
    print("NOTIFIER:\n" .. vim.inspect(Snacks.notifier.get_history()))
  end
  for _, client in ipairs(vim.lsp.get_clients()) do
    client:stop(true)
  end
  vim.cmd(ok and "qa!" or "cquit 1")
end)
