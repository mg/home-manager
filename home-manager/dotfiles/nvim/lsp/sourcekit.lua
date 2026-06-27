---@brief
--- https://github.com/apple/sourcekit-lsp
---
--- Language server for Swift. Prefer the active Xcode toolchain via xcrun
--- when available, while still allowing a Nix or custom sourcekit-lsp binary.

local root_markers = {
  "Package.swift",
  "compile_commands.json",
  ".git",
}

local function xcrun_find(tool)
  if vim.fn.executable("xcrun") ~= 1 then
    return nil
  end

  local result = vim.system({ "xcrun", "--find", tool }, { text = true }):wait()
  if result.code ~= 0 then
    return nil
  end

  local path = vim.trim(result.stdout or "")
  if path ~= "" then
    return path
  end

  return nil
end

local function sourcekit_lsp_cmd()
  if vim.env.SOURCEKIT_LSP and vim.env.SOURCEKIT_LSP ~= "" then
    return { vim.env.SOURCEKIT_LSP }
  end

  local xcode_sourcekit = xcrun_find("sourcekit-lsp")
  if xcode_sourcekit then
    return { xcode_sourcekit }
  end

  local path_sourcekit = vim.fn.exepath("sourcekit-lsp")
  if path_sourcekit ~= "" then
    return { path_sourcekit }
  end

  return { "sourcekit-lsp" }
end

---@type vim.lsp.Config
return {
  cmd = function(dispatchers)
    return vim.lsp.rpc.start(sourcekit_lsp_cmd(), dispatchers)
  end,
  filetypes = { "swift" },
  root_markers = root_markers,
  workspace_required = false,
  on_attach = function(client, bufnr)
    if client:supports_method("textDocument/inlayHint") then
      vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
    end
  end,
}
