-- Resolve Zig tools at launch time; never start a container just to probe it.
local M = {}

local function run(command, cwd)
  local ok, process = pcall(vim.system, command, { cwd = cwd, text = true, timeout = 2000 })
  if not ok then
    return nil
  end
  local result = process:wait()
  return result.code == 0 and vim.trim(result.stdout or "") or nil
end

function M.container(root)
  if not vim.env.DEVC_LANG or vim.env.DEVC_LANG == "" then
    return nil
  end
  if vim.fn.executable("fish") ~= 1 or vim.fn.executable("container") ~= 1 then
    return nil
  end
  -- Derive from the actual workspace, not a possibly stale DEVC_NAME.
  -- DEVC_LANG also supports Zig projects with a custom `use local` image.
  local name = run({ "fish", "-c", "devc name" }, root)
  if not name or name == "" then
    return nil
  end
  local running = run({ "container", "ls", "-q" }, root)
  for _, id in ipairs(vim.split(running or "", "\n", { trimempty = true })) do
    if id == name then
      return name
    end
  end
end

function M.resolve(tool, root, override, host_only)
  if override and override ~= "" then
    local path = vim.fn.exepath(override)
    if path == "" then
      return nil, "Zig: configured executable is unavailable: " .. override
    end
    return { path }, false
  end

  local name = not host_only and M.container(root) or nil
  if name then
    -- A custom image may lack this tool. Check without invoking devc run.
    local path = run(
      { "container", "exec", name, "sh", "-c", "command -v " .. vim.fn.shellescape(tool) },
      root
    )
    if path and path ~= "" then
      return { "container", "exec", "-i", "-w", root, name, tool }, true
    end
  end

  local path = vim.fn.exepath(tool)
  if path ~= "" then
    return { path }, false
  end
  return nil,
    "Zig: no running project container with " .. tool .. " and no host " .. tool .. " on PATH"
end

function M.command(command, root)
  local cmd, container_or_error = M.resolve(command[1], root, vim.env.ZIG_PATH)
  if not cmd then
    return nil, container_or_error
  end
  return vim.list_extend(cmd, { unpack(command, 2) })
end

function M.run(command, root, callback)
  local cmd, err = M.command(command, root)
  if not cmd then
    vim.notify(err, vim.log.levels.ERROR)
    return
  end
  local ok, spawn_err = pcall(vim.system, cmd, { cwd = root, text = true }, callback)
  if not ok then
    vim.notify("Zig: could not launch command: " .. tostring(spawn_err), vim.log.levels.ERROR)
  end
end

return M
