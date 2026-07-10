local function parent_process(pid)
  local result = vim
    .system({ "ps", "-p", tostring(pid), "-o", "ppid=", "-o", "command=" }, { text = true })
    :wait()
  if result.code ~= 0 then
    return nil
  end

  local line = vim.trim(result.stdout or "")
  if line == "" then
    return nil
  end

  local ppid, command = line:match("^(%d+)%s+(.+)$")
  if not ppid or not command then
    return nil
  end

  return tonumber(ppid), command
end

local function started_from_pi()
  if vim.env.PIBUF_NVIM == "1" or vim.env.PI_NVIM == "1" then
    return true
  end

  local pid = vim.uv.os_getppid()
  for _ = 1, 12 do
    if not pid or pid <= 1 then
      return false
    end

    local ppid, command = parent_process(pid)
    if not command then
      return false
    end

    local argv0 = command:match("^(%S+)")
    if
      command:match("pi%-coding%-agent") or (argv0 and vim.fn.fnamemodify(argv0, ":t") == "pi")
    then
      return true
    end

    pid = ppid
  end

  return false
end

if not started_from_pi() then
  return {}
end

return {
  src = "https://github.com/S1M0N38/pibuf.nvim",
  version = "v1.0.0",
  config = function()
    require("pibuf").setup()
  end,
}
