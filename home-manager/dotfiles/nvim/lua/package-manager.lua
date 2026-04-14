local fzf = require("fzf-lua")
local utils = require("fzf-lua.utils")

local function get_readme(path)
  if path == "" then
    return ""
  end
  for _, file in ipairs({ "README.md", "README" }) do
    local full = path .. "/" .. file
    if vim.fn.filereadable(full) == 1 then
      return full
    end
  end
  return path
end

local function run_pack_manager(only_non_active)
  local lockfile_path = vim.fn.stdpath("config") .. "/nvim-pack-lock.json"
  if vim.fn.filereadable(lockfile_path) == 0 then
    vim.notify("nvim-pack-lock.json not found", vim.log.levels.ERROR)
    return
  end

  local lock_content = table.concat(vim.fn.readfile(lockfile_path), "\n")
  local lock_data = vim.json.decode(lock_content)

  if not lock_data or not lock_data.plugins then
    vim.notify("No plugins found in lockfile", vim.log.levels.WARN)
    return
  end

  local pack_plugins = vim.pack.get()
  local pack_info = {}
  for _, p in ipairs(pack_plugins) do
    pack_info[p.spec.name] = p
  end

  local entries = {}
  local entry_to_name = {}

  for plugin_name, info in pairs(lock_data.plugins) do
    local p_data = pack_info[plugin_name] or {}
    local is_active = p_data.active or false
    local plugin_path = p_data.path or ""

    if not only_non_active or not is_active then
      local preview_file = get_readme(plugin_path)
      local display_name = utils.ansi_codes.blue(plugin_name)
      local display_rev = utils.ansi_codes.green(string.sub(info.rev or "", 1, 7))
      local display_text = string.format("[%s] %s", display_rev, display_name)
      local entry_str = string.format("%s:1:1:%s", preview_file, display_text)

      table.insert(entries, entry_str)
      entry_to_name[entry_str] = plugin_name
    end
  end

  if #entries == 0 then
    vim.notify("No plugins to display", vim.log.levels.INFO)
    return
  end

  fzf.fzf_exec(entries, {
    prompt = "vim.pack> ",
    previewer = "builtin",
    fzf_opts = {
      ["--delimiter"] = ":",
      ["--with-nth"] = "4..",
      ["--tiebreak"] = "begin",
    },
    actions = {
      ["default"] = function(selected)
        local plugin_name = entry_to_name[selected[1]]
        local p_data = pack_info[plugin_name]
        if p_data and p_data.path then
          vim.cmd("edit " .. p_data.path)
        end
      end,
      ["ctrl-u"] = function(selected)
        local plugin_name = entry_to_name[selected[1]]
        vim.pack.update({ plugin_name })
      end,
      ["ctrl-d"] = function(selected)
        local plugin_name = entry_to_name[selected[1]]
        local p_data = vim.iter(vim.pack.get()):find(function(x)
          return x.spec.name == plugin_name
        end)

        if p_data then
          if not p_data.active then
            vim.pack.del({ plugin_name })
            vim.notify("Deleted: " .. plugin_name, vim.log.levels.INFO)
          else
            vim.notify("Cannot delete active plugin: " .. plugin_name, vim.log.levels.ERROR)
          end
        else
          vim.notify("Plugin not found on disk: " .. plugin_name, vim.log.levels.WARN)
        end
      end,
    },
  })
end

vim.api.nvim_create_user_command("PackManage", function()
  run_pack_manager(false)
end, {})

vim.api.nvim_create_user_command("PackManageNonActive", function()
  run_pack_manager(true)
end, {})
