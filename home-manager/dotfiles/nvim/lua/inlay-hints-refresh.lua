local M = {}
local pending = {}

function M.refresh(bufnr)
  bufnr = vim._resolve_bufnr(bufnr)
  local token = {}
  pending[bufnr] = token

  -- ZLS can initially return partial hints while dependencies are resolving.
  -- Retry a bounded number of times, cancelling stale retries after edits.
  for _, delay in ipairs({ 100, 600, 2000 }) do
    vim.defer_fn(function()
      if pending[bufnr] ~= token or not vim.api.nvim_buf_is_loaded(bufnr) then
        return
      end
      local hints = require("inlay-hint")
      if not hints.is_enabled({ bufnr = bufnr }) then
        return
      end
      for _, client in
        ipairs(vim.lsp.get_clients({ bufnr = bufnr, method = "textDocument/inlayHint" }))
      do
        -- Invalidate the renderer's applied-line cache as well as requesting
        -- fresh hints. Calling on_inlayhint alone leaves old extmarks in place.
        hints.on_refresh(nil, nil, { client_id = client.id })
      end
    end, delay)
  end
end

function M.setup()
  local group = vim.api.nvim_create_augroup("inlay_hints_refresh", { clear = true })
  vim.api.nvim_create_user_command("InlayHintsRefresh", function()
    M.refresh(0)
  end, { desc = "Refresh inlay hints with bounded analysis retries", force = true })
  vim.api.nvim_create_autocmd({ "LspAttach", "BufEnter", "InsertLeave", "DiagnosticChanged" }, {
    group = group,
    callback = function(args)
      M.refresh(args.buf)
    end,
  })
  vim.api.nvim_create_autocmd("LspNotify", {
    group = group,
    callback = function(args)
      if
        args.data.method == "textDocument/didOpen" or args.data.method == "textDocument/didChange"
      then
        M.refresh(args.buf)
      end
    end,
  })
  vim.api.nvim_create_autocmd("BufWipeout", {
    group = group,
    callback = function(args)
      pending[args.buf] = nil
    end,
  })
end

return M
