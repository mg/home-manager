local function find_mix_root(path)
  local matches = vim.fs.find({ "mix.exs" }, { upward = true, limit = 2, path = path })
  local child_or_root_path, maybe_umbrella_path = unpack(matches)
  local mix_file = maybe_umbrella_path or child_or_root_path

  if not mix_file then
    return nil
  end

  return vim.fs.dirname(mix_file)
end

local function relative_to(root, path)
  local prefix = root .. "/"

  if path:sub(1, #prefix) ~= prefix then
    return nil
  end

  return path:sub(#prefix + 1)
end

local file = vim.api.nvim_buf_get_name(0)
local root = file ~= "" and find_mix_root(file) or nil
local rel_path = root and relative_to(root, file) or nil

if rel_path and rel_path:match("^test/") then
  vim.api.nvim_buf_create_user_command(0, "MixTestLine", function()
    if vim.bo.modified then
      local ok, err = pcall(vim.cmd, "write")
      if not ok then
        vim.notify("Failed to save buffer before running test: " .. tostring(err), vim.log.levels.ERROR)
        return
      end
    end

    local line = vim.api.nvim_win_get_cursor(0)[1]
    local spec = rel_path .. ":" .. line

    vim.cmd("botright 15new")
    vim.bo.bufhidden = "wipe"
    vim.fn.termopen({ "mix", "test", spec }, { cwd = root })
    vim.cmd("startinsert")
  end, {
    desc = "Run mix test for the current file and line",
  })

  vim.keymap.set("n", "<leader>ct", "<cmd>MixTestLine<CR>", {
    buffer = 0,
    desc = "Run [t]est at line",
  })
end
