---@brief
--- https://github.com/zigtools/zls
---
--- Zig LSP implementation + Zig Language Server.
---
--- Runs zls inside the project's dev container via `devc run zls` (mirrors
--- lsp/expert.lua). The container mounts the project at the same absolute path
--- as the host, so a zls.json path resolves identically inside the container.
--- Set $ZLS_PATH to use a local zls binary instead.

local root_markers = { 'zls.json', 'build.zig', '.git' }

---@type vim.lsp.Config
return {
  cmd = function(dispatchers, config)
    local args = {}
    local root_dir = (config or {}).root_dir or vim.fs.root(0, root_markers)

    if root_dir then
      local config_path = vim.fs.joinpath(root_dir, 'zls.json')
      if vim.fn.filereadable(config_path) == 1 then
        table.insert(args, '--config-path')
        table.insert(args, config_path)
      end
    end

    local cmd
    if vim.env.ZLS_PATH then
      cmd = { vim.env.ZLS_PATH }
      vim.list_extend(cmd, args)
    else
      -- devc run zls, with any args appended (shell-escaped for the fish -c string)
      local inner = 'devc run zls'
      for _, a in ipairs(args) do
        inner = inner .. ' ' .. vim.fn.shellescape(a)
      end
      cmd = { 'fish', '-c', inner }
    end

    return vim.lsp.rpc.start(cmd, dispatchers)
  end,
  filetypes = { 'zig', 'zir' },
  root_markers = root_markers,
  workspace_required = false,
  on_attach = function(client, bufnr)
    if client:supports_method('textDocument/inlayHint') then
      vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
    end
  end,
}
