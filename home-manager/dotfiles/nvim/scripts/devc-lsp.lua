-- Host-side stdio lifetime bridge, run with: nvim -l devc-lsp.lua COMMAND [ARG ...]
-- No editor config/plugins or external Lua/Python runtime are loaded. Neovim
-- signals this supervisor, not fish/container exec. stdout/stderr pass through.
local uv = vim.uv

-- Bash/coreutils/grep are already in dev-base. Send this as an argument so
-- existing images need no rebuild. Only the server inherits the session token:
-- /proc/environ finds even children that daemonize (Expert's project engine),
-- without matching the supervisor or another editor's server.
local guest = [=[
set -u
token=$1
shift
tmp=$(mktemp -d /tmp/devc-lsp.XXXXXXXX) || exit 1
mkfifo "$tmp/stdin" || { rmdir "$tmp"; exit 1; }

session_pids() {
    local entry pid
    for entry in /proc/[0-9]*/environ; do
        if grep -zFxq -- "DEVC_LSP_SESSION=$token" "$entry" 2>/dev/null; then
            pid=${entry#/proc/}
            printf '%s\n' "${pid%/environ}"
        fi
    done
}

# Preserve stdin explicitly: asynchronous shell commands otherwise get /dev/null.
cat <&0 >"$tmp/stdin" &
relay=$!
env "DEVC_LSP_SESSION=$token" "$@" <"$tmp/stdin" &
server=$!

# Finish when either the server exits normally or the host closes stdin. An EOF
# must stop the server even if it doesn't read/handle stdin itself.
status=0
wait -n "$relay" "$server" || status=$?
kill "$relay" 2>/dev/null || true
pids=$(session_pids)
if [ -n "$pids" ]; then
    kill -TERM $pids 2>/dev/null || true
    # Allow Erlang to flush its index; bound cleanup for a hung/crashed server.
    deadline=$((SECONDS + 5))
    while ((SECONDS < deadline)); do
        pids=$(session_pids)
        [ -z "$pids" ] && break
        sleep 0.1
    done
    pids=$(session_pids)
    if [ -n "$pids" ]; then
        echo 'devc-lsp: forcing shutdown of unresponsive session processes' >&2
        kill -KILL $pids 2>/dev/null || true
    fi
fi
wait "$server" 2>/dev/null || true
wait "$relay" 2>/dev/null || true
rm -rf -- "$tmp"
exit "$status"
]=]

if not arg[1] then
  io.stderr:write("usage: nvim -l devc-lsp.lua COMMAND [ARG ...]\n")
  os.exit(1)
end

-- Fish single quotes still interpret \\ and \'. Don't use shellescape(), which
-- depends on the editor's configured shell rather than the fish we spawn.
local function quote(value)
  return "'" .. value:gsub("\\", "\\\\"):gsub("'", "\\'") .. "'"
end
local token = assert(uv.random(16)):gsub(".", function(byte)
  return string.format("%02x", byte:byte())
end)
local command = { "devc", "run", "bash", "-c", guest, "devc-lsp", token }
for _, value in ipairs(arg) do
  command[#command + 1] = value
end
for i, value in ipairs(command) do
  command[i] = quote(value)
end

local input = assert(uv.new_pipe(false))
assert(input:open(0))
local child_input = assert(uv.new_pipe(false))
local timeout = assert(uv.new_timer())
local signals = {}
local stopping, exited, timed_out = false, false, false
local exit_code = 0
local process, pid

local function close(handle)
  if handle and not handle:is_closing() then
    handle:close()
  end
end

local function stop()
  if stopping or exited then
    return
  end
  stopping = true
  input:read_stop()
  close(input)
  -- Closing (not draining) the pipe stays responsive even if the guest is hung
  -- and a write is pending. This EOF is the guest supervisor's lifetime signal.
  close(child_input)
  timeout:start(15000, 0, function()
    timed_out = true
    io.stderr:write("devc-lsp: container cleanup timed out; check guest processes\n")
    -- Never leak the host fish/exec group on a broken container connection.
    -- Killing it is NOT proof that the guest was successfully stopped.
    uv.kill(-pid, "sigkill")
  end)
end

for _, signame in ipairs({ "sigterm", "sigint", "sighup" }) do
  local handle = assert(uv.new_signal())
  assert(handle:start(signame, stop))
  signals[#signals + 1] = handle
end

process, pid = uv.spawn("fish", {
  args = { "-c", table.concat(command, " ") },
  stdio = { child_input, 1, 2 },
  detached = true, -- separate host process group, as with start_new_session
}, function(code, signal)
  exited = true
  exit_code = timed_out and 1 or (stopping and 0 or (signal ~= 0 and 128 + signal or code))
  close(input)
  close(child_input)
  close(timeout)
  for _, handle in ipairs(signals) do
    close(handle)
  end
  close(process)
end)
if not process then
  io.stderr:write("devc-lsp: could not start fish: " .. tostring(pid) .. "\n")
  os.exit(1)
end

local read
read = function()
  if stopping or exited then
    return
  end
  input:read_start(function(err, data)
    if stopping or exited then
      return
    end
    if err or not data then
      if err then
        io.stderr:write("devc-lsp: stdin: " .. err .. "\n")
      end
      stop()
      return
    end
    -- One chunk in flight: bound memory and avoid blocking signal handling when
    -- a server stops consuming input. Resume only once that write has completed.
    input:read_stop()
    local request = child_input:write(data, function(write_err)
      if write_err then
        stop()
      else
        read()
      end
    end)
    if not request then
      stop()
    end
  end)
end
read()

-- Pump libuv directly, not vim.wait/the editor event loop. Neovim's own signal
-- events must not exit the supervisor before the guest cleanup has completed.
while not exited do
  uv.run("once")
end
os.exit(exit_code)
