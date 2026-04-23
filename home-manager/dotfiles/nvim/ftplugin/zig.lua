local function find_root(path)
  return vim.fs.root(path, { "build.zig", "zls.json", ".git" }) or vim.fs.dirname(path)
end

local zig_errorformat = table.concat({
  "%E%f:%l:%c: error: %m",
  "%W%f:%l:%c: warning: %m",
  "%I%f:%l:%c: note: %m",
  "%-G%.%#",
}, ",")

local function write_buffer()
  if not vim.bo.modified then
    return true
  end

  local ok, err = pcall(vim.cmd, "write")
  if not ok then
    vim.notify("Failed to save buffer before running command: " .. tostring(err), vim.log.levels.ERROR)
    return false
  end

  return true
end

local function command_output_lines(result)
  local output = table.concat({ result.stdout or "", result.stderr or "" }, "")
  return vim.split(output, "\n", { trimempty = true })
end

local function open_output_window(lines)
  vim.cmd("botright 12new")
  vim.bo.buftype = "nofile"
  vim.bo.bufhidden = "wipe"
  vim.bo.swapfile = false
  vim.bo.modifiable = true
  vim.api.nvim_buf_set_lines(0, 0, -1, false, #lines > 0 and lines or { "" })
  vim.bo.modifiable = false
  vim.cmd("normal! gg")
end

local function open_quickfix_or_output(title, lines)
  vim.fn.setqflist({}, " ", {
    title = title,
    lines = lines,
    efm = zig_errorformat,
  })

  if #vim.fn.getqflist() > 0 then
    vim.cmd("copen")
  else
    open_output_window(lines)
  end
end

local function nearest_named_test()
  local ok, parser = pcall(vim.treesitter.get_parser, 0, "zig")
  if not ok or not parser then
    vim.notify("Zig treesitter parser is not available", vim.log.levels.ERROR)
    return nil
  end

  local cursor = vim.api.nvim_win_get_cursor(0)
  local row = cursor[1] - 1
  local col = cursor[2]
  local tree = parser:parse()[1]
  if not tree then
    return nil
  end

  local node = tree:root():named_descendant_for_range(row, col, row, col)
  while node and node:type() ~= "test_declaration" do
    node = node:parent()
  end

  if not node then
    return nil
  end

  for child in node:iter_children() do
    if child:type() == "string" then
      local text = vim.treesitter.get_node_text(child, 0)
      if not text or text == "" then
        break
      end

      local ok_decode, decoded = pcall(vim.json.decode, text)
      if ok_decode and type(decoded) == "string" then
        return decoded
      end

      return text:sub(2, -2)
    end
  end

  return false
end

local function zig_build_command(root, file)
  if vim.fn.filereadable(vim.fs.joinpath(root, "build.zig")) == 1 then
    return { "zig", "build", "-Doptimize=Debug" }, "Built project with zig build"
  end

  local executable = vim.fs.joinpath(root, vim.fn.fnamemodify(file, ":t:r"))
  return {
    "zig",
    "build-exe",
    "-O",
    "Debug",
    file,
    "-femit-bin=" .. executable,
  }, "Built " .. vim.fn.fnamemodify(executable, ":~:.")
end

local function zig_run_command(root, file)
  if vim.fn.filereadable(vim.fs.joinpath(root, "build.zig")) == 1 then
    return { "zig", "build", "run", "-Doptimize=Debug" }, "Ran project with zig build run"
  end

  return { "zig", "run", file }, "Ran " .. vim.fn.fnamemodify(file, ":~:.")
end

vim.api.nvim_buf_create_user_command(0, "ZigBuild", function()
  local file = vim.api.nvim_buf_get_name(0)
  if file == "" then
    vim.notify("Current buffer has no file name", vim.log.levels.ERROR)
    return
  end

  if not write_buffer() then
    return
  end

  local root = find_root(file)
  local command, success_message = zig_build_command(root, file)

  vim.system(command, { cwd = root, text = true }, function(result)
    vim.schedule(function()
      local lines = command_output_lines(result)

      if result.code == 0 then
        vim.fn.setqflist({}, "r")
        vim.cmd("cclose")
        vim.notify(success_message, vim.log.levels.INFO)
        return
      end

      vim.fn.setqflist({}, " ", {
        title = "ZigBuild",
        lines = lines,
        efm = zig_errorformat,
      })
      vim.cmd("copen")
      vim.notify("Zig build failed", vim.log.levels.ERROR)
    end)
  end)
end, {
  desc = "Build the current Zig file",
})

vim.api.nvim_buf_create_user_command(0, "ZigRun", function()
  local file = vim.api.nvim_buf_get_name(0)
  if file == "" then
    vim.notify("Current buffer has no file name", vim.log.levels.ERROR)
    return
  end

  if not write_buffer() then
    return
  end

  local root = find_root(file)
  local command, success_message = zig_run_command(root, file)

  vim.system(command, { cwd = root, text = true }, function(result)
    vim.schedule(function()
      local lines = command_output_lines(result)

      if result.code == 0 then
        vim.fn.setqflist({}, "r")
        vim.cmd("cclose")
        if #lines > 0 then
          open_output_window(lines)
        end
        vim.notify(success_message, vim.log.levels.INFO)
        return
      end

      open_quickfix_or_output("ZigRun", lines)
      vim.notify("Zig run failed", vim.log.levels.ERROR)
    end)
  end)
end, {
  desc = "Build and run the current Zig file",
})

vim.api.nvim_buf_create_user_command(0, "ZigTestNearest", function()
  local file = vim.api.nvim_buf_get_name(0)
  if file == "" then
    vim.notify("Current buffer has no file name", vim.log.levels.ERROR)
    return
  end

  if not write_buffer() then
    return
  end

  local test_name = nearest_named_test()
  if test_name == nil then
    vim.notify("Cursor is not inside a Zig test", vim.log.levels.WARN)
    return
  end

  if test_name == false then
    vim.notify("Anonymous Zig tests cannot be run by name", vim.log.levels.WARN)
    return
  end

  local root = find_root(file)
  local command = { "zig", "test", "-O", "Debug", "--test-filter", test_name, file }

  vim.system(command, { cwd = root, text = true }, function(result)
    vim.schedule(function()
      local lines = command_output_lines(result)

      if result.code == 0 then
        vim.fn.setqflist({}, "r")
        vim.cmd("cclose")
        if #lines > 0 then
          open_output_window(lines)
        end
        vim.notify("Zig test passed: " .. test_name, vim.log.levels.INFO)
        return
      end

      open_quickfix_or_output("ZigTestNearest", lines)
      vim.notify("Zig test failed: " .. test_name, vim.log.levels.ERROR)
    end)
  end)
end, {
  desc = "Run the Zig test at the cursor",
})

vim.api.nvim_buf_create_user_command(0, "ZigTestFile", function()
  local file = vim.api.nvim_buf_get_name(0)
  if file == "" then
    vim.notify("Current buffer has no file name", vim.log.levels.ERROR)
    return
  end

  if not write_buffer() then
    return
  end

  local root = find_root(file)
  local command = { "zig", "test", "-O", "Debug", file }

  vim.system(command, { cwd = root, text = true }, function(result)
    vim.schedule(function()
      local lines = command_output_lines(result)

      if result.code == 0 then
        vim.fn.setqflist({}, "r")
        vim.cmd("cclose")
        if #lines > 0 then
          open_output_window(lines)
        end
        vim.notify("Zig test file passed: " .. vim.fn.fnamemodify(file, ":~:."), vim.log.levels.INFO)
        return
      end

      open_quickfix_or_output("ZigTestFile", lines)
      vim.notify("Zig test file failed: " .. vim.fn.fnamemodify(file, ":~:."), vim.log.levels.ERROR)
    end)
  end)
end, {
  desc = "Run all Zig tests in the current file",
})

vim.keymap.set("n", "<leader>ct", "<cmd>ZigTestNearest<CR>", {
  buffer = 0,
  desc = "Run [t]est at cursor",
})

vim.keymap.set("n", "<leader>cT", "<cmd>ZigTestFile<CR>", {
  buffer = 0,
  desc = "Run all [T]ests in file",
})

vim.keymap.set("n", "<F4>", "<cmd>ZigRun<CR>", {
  buffer = 0,
  desc = "Build and run current Zig file",
})

vim.keymap.set("n", "<S-F4>", "<cmd>ZigBuild<CR>", {
  buffer = 0,
  desc = "Build current Zig file",
})
