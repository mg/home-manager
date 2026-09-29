-- Enabled instead of host ty in a direnv-activated devc session (including
-- `use local`). The image supplies BasedPyright and its Node runtime; it
-- discovers the Linux .venv on the same-path project mount itself.
---@type vim.lsp.Config
return {
  cmd = require("devc-lsp")({ "basedpyright-langserver", "--stdio" }),
  before_init = function(params)
    -- The host Neovim PID doesn't exist in the container. Otherwise the server
    -- monitors an unrelated/missing guest PID and exits a few seconds later.
    params.processId = vim.NIL
  end,
  capabilities = {
    workspace = { didChangeWatchedFiles = { dynamicRegistration = false } },
  }, -- Let the guest watch its files, not macOS (/usr/local and Linux venv paths).
  filetypes = { "python" },
  root_markers = {
    "pyrightconfig.json",
    "pyproject.toml",
    "setup.py",
    "setup.cfg",
    "requirements.txt",
    ".git",
  },
  settings = {
    basedpyright = {
      disableOrganizeImports = true, -- Ruff owns formatting and import actions.
    },
  },
}
