---@brief
---
--- https://github.com/elixir-lang/expert
---
--- Expert is the official language server implementation for the Elixir programming language.
---
--- 'root_dir' is chosen like this: if two or more directories containing `mix.exs` were found when
--- searching directories upward, the second one (higher up) is chosen, with the assumption that it
--- is the root of an umbrella app. Otherwise the directory containing the single mix.exs that was
--- found is chosen.

---@type vim.lsp.Config
return {
  filetypes = { 'elixir', 'eelixir', 'heex', 'surface' },
  cmd = require('devc-lsp')({ 'expert', '--stdio' }),
  -- Give Expert time to flush its index on a normal LSP shutdown. Forced
  -- termination then cleans up this session in the guest, not just host fish.
  exit_timeout = 10000,
  root_dir = function(bufnr, on_dir)
    local fname = vim.api.nvim_buf_get_name(bufnr)
    --- Elixir workspaces may have multiple `mix.exs` files, for an "umbrella" layout or monorepo.
    --- So we specify `limit=2` and treat the highest one (if any) as the root of an umbrella app.
    local matches = vim.fs.find({ 'mix.exs' }, { upward = true, limit = 2, path = fname })
    local child_or_root_path, maybe_umbrella_path = unpack(matches)
    local root_dir = vim.fs.dirname(maybe_umbrella_path or child_or_root_path)

    on_dir(root_dir)
  end,
}
