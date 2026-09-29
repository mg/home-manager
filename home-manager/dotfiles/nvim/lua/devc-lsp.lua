-- Keep the host supervisor alive until the guest server AND its children exit.
-- Neovim's restart waits for this process, so it cannot overlap the old session.
-- The supervisor uses devc for naming/startup/cwd/environment forwarding.
return function(command)
  return vim.list_extend({
    vim.v.progpath,
    "-l", -- standalone Lua mode: no config, plugins, swapfiles, or ShaDa
    vim.fn.stdpath("config") .. "/scripts/devc-lsp.lua",
  }, command)
end
