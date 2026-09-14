---@brief
---
--- https://github.com/astral-sh/ruff
---
--- A Language Server Protocol implementation for Ruff, an extremely fast Python linter and code formatter, written in Rust. It can be installed via `pip`.
---
--- ```sh
--- pip install ruff
--- ```
---
--- **Available in Ruff `v0.4.5` in beta and stabilized in Ruff `v0.5.3`.**
---
--- This is the new built-in language server written in Rust. It supports the same feature set as `ruff-lsp`, but with superior performance and no installation required. Note that the `ruff-lsp` server will continue to be maintained until further notice.
---
--- Server settings can be provided via:
---
--- ```lua
--- vim.lsp.config('ruff', {
---   init_options = {
---     settings = {
---       -- Server settings should go here
---     }
---   }
--- })
--- ```
---
--- Refer to the [documentation](https://docs.astral.sh/ruff/editors/) for more details.

local root_markers = { 'pyproject.toml', 'ruff.toml', '.ruff.toml', '.git' }

---@type vim.lsp.Config
return {
  cmd = vim.env.DEVC_LANG and vim.env.DEVC_LANG ~= ''
    and { 'fish', '-c', 'devc run ruff server' }
    or { 'ruff', 'server' },
  before_init = function(params)
    if vim.env.DEVC_LANG and vim.env.DEVC_LANG ~= '' then
      params.processId = vim.NIL -- host PID is not meaningful inside the VM
    end
  end,
  -- Request static formatting capabilities so the shared LspAttach handler
  -- can install format-on-save before Ruff registers dynamic capabilities.
  capabilities = {
    textDocument = {
      formatting = { dynamicRegistration = false },
      rangeFormatting = { dynamicRegistration = false },
    },
  },
  filetypes = { 'python' },
  root_markers = root_markers,
  root_dir = function(bufnr, on_dir)
    -- Neovim sends unnamed buffers as file:///. Ruff 0.16 panics when linting
    -- that URI because it has no parent directory. A named but unsaved file
    -- is fine; no need to require that it already exists on disk.
    if vim.api.nvim_buf_get_name(bufnr) == '' then
      return
    end
    on_dir(vim.fs.root(bufnr, root_markers))
  end,
  settings = {},
}
