local function package_root(path)
  return vim.fs.root(path, { "Package.swift" })
end

local function swift_command(args)
  if vim.fn.executable("swift") == 1 then
    return vim.list_extend({ "swift" }, args)
  end

  if vim.fn.executable("xcrun") == 1 then
    return vim.list_extend({ "xcrun", "swift" }, args)
  end

  vim.notify("swift is not on PATH and xcrun is unavailable", vim.log.levels.ERROR)
  return nil
end

local function write_buffer()
  if not vim.bo.modified then
    return true
  end

  local ok, err = pcall(vim.cmd, "write")
  if not ok then
    vim.notify(
      "Failed to save buffer before running Swift command: " .. tostring(err),
      vim.log.levels.ERROR
    )
    return false
  end

  return true
end

local function run_in_terminal(command, root)
  vim.cmd("botright 15new")
  vim.bo.bufhidden = "wipe"
  vim.fn.termopen(command, { cwd = root })
  vim.cmd("startinsert")
end

local function run_swift(args)
  if not write_buffer() then
    return
  end

  local file = vim.api.nvim_buf_get_name(0)
  local root = package_root(file) or vim.fn.getcwd()
  local command = swift_command(args)
  if command then
    run_in_terminal(command, root)
  end
end

local test_name_patterns = {
  "^%s*func%s+(test[%w_]+)%s*%(",
  "^%s*@Test.-func%s+([%w_]+)%s*%(",
  "^%s*func%s+([%w_]+)%s*%(",
}

local function line_test_name(line)
  for _, pattern in ipairs(test_name_patterns) do
    local name = line:match(pattern)
    if name and name ~= "" then
      return name
    end
  end

  return nil
end

local function nearest_test_name()
  local cursor_line = vim.api.nvim_win_get_cursor(0)[1]
  local lines = vim.api.nvim_buf_get_lines(0, 0, cursor_line, false)

  for i = #lines, 1, -1 do
    local name = line_test_name(lines[i])
    if name then
      return name
    end
  end

  return nil
end

vim.api.nvim_buf_create_user_command(0, "SwiftBuild", function()
  run_swift({ "build" })
end, { desc = "Run swift build" })

vim.api.nvim_buf_create_user_command(0, "SwiftRun", function()
  run_swift({ "run" })
end, { desc = "Run swift run" })

vim.api.nvim_buf_create_user_command(0, "SwiftTestFile", function()
  run_swift({ "test" })
end, { desc = "Run swift test" })

vim.api.nvim_buf_create_user_command(0, "SwiftTestNearest", function()
  local name = nearest_test_name()
  if not name then
    vim.notify("Cursor is not inside a Swift test", vim.log.levels.WARN)
    return
  end

  run_swift({ "test", "--filter", name })
end, { desc = "Run the Swift test nearest the cursor" })

vim.keymap.set("n", "<leader>cb", "<cmd>SwiftBuild<CR>", {
  buffer = 0,
  desc = "Swift [b]uild",
})

vim.keymap.set("n", "<leader>cr", "<cmd>SwiftRun<CR>", {
  buffer = 0,
  desc = "Swift [r]un",
})

vim.keymap.set("n", "<leader>ct", "<cmd>SwiftTestNearest<CR>", {
  buffer = 0,
  desc = "Run [t]est at cursor",
})

vim.keymap.set("n", "<leader>cT", "<cmd>SwiftTestFile<CR>", {
  buffer = 0,
  desc = "Run all Swift [T]ests",
})
