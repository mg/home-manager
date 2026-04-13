-- Auto-discover and load vim.pack specs from lua/packages/*.lua
-- Each file should return either:
--   { src = "...", config = function() ... end }       -- single spec
--   { { src = "..." }, { src = "..." }, config = ... } -- multiple specs

local config_dir = vim.fn.stdpath("config") .. "/lua/packages"
local files = vim.fn.glob(config_dir .. "/*.lua", false, true)
table.sort(files)

for _, file in ipairs(files) do
  local module = "packages." .. vim.fn.fnamemodify(file, ":t:r")
  local ok, spec = pcall(require, module)
  if ok and spec then
    local config = spec.config
    local keys = spec.keys
    spec.config = nil
    spec.keys = nil

    if spec.src then
      -- Single spec: { src = "..." }
      vim.pack.add({ spec })
    else
      -- List of specs: { { src = "..." }, { src = "..." } }
      local specs = {}
      for i, s in ipairs(spec) do
        specs[i] = s
      end
      if #specs > 0 then
        vim.pack.add(specs)
      end
    end

    if config then
      config()
    end

    -- Apply keymaps: { lhs, rhs, desc = "...", mode = "..." }
    if keys then
      for _, key in ipairs(keys) do
        local lhs = key[1]
        local rhs = key[2]
        local mode = key.mode or "n"
        local opts = { desc = key.desc, remap = key.remap, nowait = key.nowait, silent = key.silent }
        vim.keymap.set(mode, lhs, rhs, opts)
      end
    end
  else
    vim.notify("Failed to load package spec: " .. module .. "\n" .. tostring(spec), vim.log.levels.ERROR)
  end
end
