local M = {}

--- Check if the current buffer is inside a git repository.
---@return boolean
function M.is_git_project()
  return vim.fs.root(0, '.git') ~= nil
end

--- Check if the current working directory is under ~/Work.
---@return boolean
function M.is_work_dir()
  local cwd = vim.fn.getcwd()
  local work_dir = vim.fn.expand("~/Work")
  return cwd:sub(1, #work_dir) == work_dir
end

return M
