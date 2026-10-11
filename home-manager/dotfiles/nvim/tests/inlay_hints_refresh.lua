-- Run from the Neovim config directory:
-- nvim --headless -u NONE -l tests/inlay_hints_refresh.lua
vim.opt.runtimepath:prepend(vim.fn.getcwd())
local timers, refreshes = {}, 0
local original_defer, original_clients = vim.defer_fn, vim.lsp.get_clients
local enabled = true
vim.defer_fn = function(callback, delay)
  timers[#timers + 1] = { callback = callback, delay = delay }
end
vim.lsp.get_clients = function()
  return { { id = 123 } }
end
package.loaded["inlay-hint"] = {
  is_enabled = function()
    return enabled
  end,
  on_refresh = function(_, _, ctx)
    assert(ctx.client_id == 123)
    refreshes = refreshes + 1
  end,
}
local module = require("inlay-hints-refresh")
module.setup()
assert(vim.fn.exists(":InlayHintsRefresh") == 2)
vim.cmd("InlayHintsRefresh")
assert(#timers == 3 and timers[3].delay == 2000)
for _, timer in ipairs(timers) do
  timer.callback()
end
assert(refreshes == 3)
timers = {}
module.refresh(0)
module.refresh(0)
for _, timer in ipairs(timers) do
  timer.callback()
end
assert(refreshes == 6, "stale retries must be cancelled")
timers = {}
module.refresh(0)
enabled = false
for _, timer in ipairs(timers) do
  timer.callback()
end
assert(refreshes == 6, "disabled hints must remain disabled")
timers = {}
enabled = true
vim.api.nvim_exec_autocmds("InsertLeave", { buffer = 0 })
assert(#timers == 3, "automatic refresh registered")
vim.defer_fn, vim.lsp.get_clients = original_defer, original_clients
print("PASS: manual/automatic refresh, bounded retries, stale cancellation, disabled hints")
vim.cmd("qa!")
