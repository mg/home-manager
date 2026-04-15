local M = {}

--- Check if the current buffer is inside a git repository.
---@return boolean
function M.is_git_project()
  return vim.fs.root(0, '.git') ~= nil
end

return M
