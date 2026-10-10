---@brief
--- https://github.com/zigtools/zls
---
--- Zig LSP implementation + Zig Language Server.
---
--- Prefer a running project container, otherwise host ZLS. Container ZLS uses
--- the lifecycle supervisor; host ZLS uses native stdio. ZLS_PATH overrides both.

local root_markers = { "zls.json", "build.zig", ".git" }

---@type vim.lsp.Config
return {
  cmd = function(dispatchers, config)
    local args = {}
    local root_dir = (config or {}).root_dir or vim.fs.root(0, root_markers) or vim.fn.getcwd()

    if root_dir then
      local config_path = vim.fs.joinpath(root_dir, "zls.json")
      if vim.fn.filereadable(config_path) == 1 then
        table.insert(args, "--config-path")
        table.insert(args, config_path)
      end
    end

    local tools = require("zig-tools")
    local _, compiler_in_container = tools.resolve("zig", root_dir, vim.env.ZIG_PATH)
    local cmd, container_or_error =
      tools.resolve("zls", root_dir, vim.env.ZLS_PATH, compiler_in_container ~= true)
    if not cmd then
      error(container_or_error)
    end
    if container_or_error then
      cmd = require("devc-lsp")(vim.list_extend({ "zls" }, args))
    else
      vim.list_extend(cmd, args)
    end

    return vim.lsp.rpc.start(cmd, dispatchers, { cwd = root_dir })
  end,
  filetypes = { "zig", "zir" },
  root_markers = root_markers,
  workspace_required = false,
  on_attach = function(client, bufnr)
    if client:supports_method("textDocument/inlayHint") then
      vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
    end
  end,
}
