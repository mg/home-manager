return {
  src = "https://github.com/felpafel/inlay-hint.nvim",
  config = function()
    -- Disable native hints before the plugin replaces the API and renderer.
    -- Supporting LSP clients enable the plugin below, not native rendering.
    vim.lsp.inlay_hint.enable(false)
    require("inlay-hint").setup({
      virt_text_pos = "eol",
    })
    require("inlay-hints-refresh").setup()

    local restore = {}
    local group = vim.api.nvim_create_augroup("inlay_hints_insert_mode", { clear = true })
    vim.api.nvim_create_autocmd("LspAttach", {
      group = group,
      callback = function(args)
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        if not client or not client:supports_method("textDocument/inlayHint", args.buf) then
          return
        end
        if vim.api.nvim_get_mode().mode:sub(1, 1) == "i" then
          -- A server can attach while typing; defer visibility until InsertLeave.
          restore[args.buf] = true
        else
          require("inlay-hint").enable(true, { bufnr = args.buf })
          require("inlay-hints-refresh").refresh(args.buf)
        end
      end,
    })
    vim.api.nvim_create_autocmd("InsertEnter", {
      group = group,
      callback = function(args)
        local hints = require("inlay-hint")
        restore[args.buf] = hints.is_enabled({ bufnr = args.buf })
        if restore[args.buf] then
          hints.enable(false, { bufnr = args.buf })
        end
      end,
    })
    vim.api.nvim_create_autocmd("InsertLeave", {
      group = group,
      callback = function(args)
        if restore[args.buf] then
          require("inlay-hint").enable(true, { bufnr = args.buf })
          require("inlay-hints-refresh").refresh(args.buf)
        end
        restore[args.buf] = nil
      end,
    })
    vim.api.nvim_create_autocmd("BufWipeout", {
      group = group,
      callback = function(args)
        restore[args.buf] = nil
      end,
    })
  end,
}
