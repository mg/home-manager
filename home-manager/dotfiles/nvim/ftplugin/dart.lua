local function find_pubspec_root(path)
  return vim.fs.root(path, { "pubspec.yaml" })
end

local function relative_to(root, path)
  local prefix = root .. "/"

  if path:sub(1, #prefix) ~= prefix then
    return nil
  end

  return path:sub(#prefix + 1)
end

local function write_buffer()
  if not vim.bo.modified then
    return true
  end

  local ok, err = pcall(vim.cmd, "write")
  if not ok then
    vim.notify("Failed to save buffer before running test: " .. tostring(err), vim.log.levels.ERROR)
    return false
  end

  return true
end

local function pubspec_uses_flutter(root)
  local pubspec = vim.fs.joinpath(root, "pubspec.yaml")
  local lines = vim.fn.readfile(pubspec)

  for _, line in ipairs(lines) do
    if line:match("sdk:%s*flutter") or line:match("^flutter:%s*$") then
      return true
    end
  end

  return false
end

local function test_command(root, rel_path, test_name)
  local uses_flutter = pubspec_uses_flutter(root)

  if uses_flutter then
    if vim.fn.executable("flutter") ~= 1 then
      vim.notify("flutter is not on PATH", vim.log.levels.ERROR)
      return nil
    end

    local command = { "flutter", "test" }
    if test_name then
      vim.list_extend(command, { "--plain-name", test_name })
    end
    table.insert(command, rel_path)
    return command
  end

  if vim.fn.executable("dart") ~= 1 then
    vim.notify("dart is not on PATH", vim.log.levels.ERROR)
    return nil
  end

  local command = { "dart", "test" }
  if test_name then
    vim.list_extend(command, { "--plain-name", test_name })
  end
  table.insert(command, rel_path)
  return command
end

local test_name_patterns = {
  "^%s*testWidgets%s*%(%s*([\"'])(.-)%1",
  "[^%w_]testWidgets%s*%(%s*([\"'])(.-)%1",
  "^%s*test%s*%(%s*([\"'])(.-)%1",
  "[^%w_]test%s*%(%s*([\"'])(.-)%1",
}

local function line_test_name(line)
  for _, pattern in ipairs(test_name_patterns) do
    local _, name = line:match(pattern)
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

local function run_test(command, root)
  vim.cmd("botright 15new")
  vim.bo.bufhidden = "wipe"
  vim.fn.termopen(command, { cwd = root })
  vim.cmd("startinsert")
end

local file = vim.api.nvim_buf_get_name(0)
local root = file ~= "" and find_pubspec_root(file) or nil
local rel_path = root and relative_to(root, file) or nil

if rel_path and rel_path:match("_test%.dart$") then
  vim.api.nvim_buf_create_user_command(0, "FlutterTestNearest", function()
    if not write_buffer() then
      return
    end

    local name = nearest_test_name()
    if not name then
      vim.notify("Cursor is not inside a Dart/Flutter test", vim.log.levels.WARN)
      return
    end

    local command = test_command(root, rel_path, name)
    if command then
      run_test(command, root)
    end
  end, {
    desc = "Run the Dart/Flutter test nearest the cursor",
  })

  vim.api.nvim_buf_create_user_command(0, "FlutterTestFile", function()
    if not write_buffer() then
      return
    end

    local command = test_command(root, rel_path)
    if command then
      run_test(command, root)
    end
  end, {
    desc = "Run all Dart/Flutter tests in the current file",
  })

  vim.keymap.set("n", "<leader>ct", "<cmd>FlutterTestNearest<CR>", {
    buffer = 0,
    desc = "Run [t]est at cursor",
  })

  vim.keymap.set("n", "<leader>cT", "<cmd>FlutterTestFile<CR>", {
    buffer = 0,
    desc = "Run all [T]ests in file",
  })
end
