---@brief
--- https://github.com/zigtools/zls
---
--- Zig LSP implementation + Zig Language Server

local root_markers = { 'zls.json', 'build.zig', '.git' }

---@type vim.lsp.Config
return {
  cmd = function(dispatchers, config)
    local cmd = { vim.env.ZLS_PATH or 'zls' }
    local root_dir = (config or {}).root_dir or vim.fs.root(0, root_markers)

    if root_dir then
      local config_path = vim.fs.joinpath(root_dir, 'zls.json')
      if vim.fn.filereadable(config_path) == 1 then
        table.insert(cmd, '--config-path')
        table.insert(cmd, config_path)
      end
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
