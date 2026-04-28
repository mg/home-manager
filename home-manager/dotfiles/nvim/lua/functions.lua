local function copy_to_clipboard(content, message)
  vim.fn.setreg('+', content)
  vim.notify('Copied "' .. content .. '" to the clipboard!', vim.log.levels.INFO)
end

vim.api.nvim_create_user_command('CopyRelativePath', function()
  local path = vim.fn.expand('%')
  copy_to_clipboard(path, 'Copied "' .. path .. '" to the clipboard!')
end, {})

vim.api.nvim_create_user_command('CopyAbsolutePath', function()
  local path = vim.fn.expand('%:p')
  copy_to_clipboard(path, 'Copied "' .. path .. '" to the clipboard!')
end, {})

vim.api.nvim_create_user_command('CopyRelativePathWithLine', function()
  local path = vim.fn.expand('%')
  local line = vim.fn.line('.')
  local result = path .. ':' .. line
  copy_to_clipboard(result, 'Copied "' .. result .. '" to the clipboard!')
end, {})

vim.api.nvim_create_user_command('CopyAbsolutePathWithLine', function()
  local path = vim.fn.expand('%:p')
  local line = vim.fn.line('.')
  local result = path .. ':' .. line
  copy_to_clipboard(result, 'Copied "' .. result .. '" to the clipboard!')
end, {})

vim.api.nvim_create_user_command('CopyFileName', function()
  local path = vim.fn.expand('%:t')
  copy_to_clipboard(path, 'Copied "' .. path .. '" to the clipboard!')
end, {})

vim.api.nvim_create_user_command('Scratch', function()
  vim.cmd('new | setlocal buftype=nofile bufhidden=hide noswapfile')
end, { desc = 'Open a scratch buffer' })

-- Keep :Open generic and route to an app based on the current buffer.
--
-- Structure notes:
-- - Each entry describes one "open this kind of file with this app" rule.
-- - The first matching handler wins, so order matters if rules ever overlap.
-- - We support three kinds of matching:
--   1. filetypes   -> Vim/Neovim filetype, e.g. "markdown"
--   2. extensions  -> filename extension, e.g. "md", "pdf"
--   3. match()     -> custom logic for more specific/project-specific rules later
--
-- That gives us a simple place to add more apps in the future without changing
-- the :Open command itself.
local open_handlers = {
  {
    app = 'Typora',
    filetypes = { markdown = true },
    extensions = {
      md = true,
      markdown = true,
      mdx = true,
    },
  },
}

-- Validate that the current buffer is a normal file-backed buffer and return its path.
local function get_current_file(bufnr)
  if vim.bo[bufnr].buftype ~= '' then
    return nil, 'Current buffer is not a file'
  end

  local file = vim.api.nvim_buf_get_name(bufnr)
  if file == '' then
    return nil, 'Current buffer has no file path. Save it first.'
  end

  return file
end

-- Save before opening so the external app sees the latest contents.
local function save_buffer_if_modified(bufnr)
  if not vim.bo[bufnr].modified then
    return true
  end

  local ok, err = pcall(function()
    vim.cmd('write')
  end)

  if not ok then
    return nil, err
  end

  return true
end

-- A handler can match via a custom predicate, filetype, or extension.
-- Custom match() is checked first so future special cases can override generic rules.
local function handler_matches(handler, bufnr, file)
  local filetype = vim.bo[bufnr].filetype
  local extension = vim.fn.fnamemodify(file, ':e'):lower()

  if handler.match and handler.match(bufnr, file) then
    return true
  end

  if handler.filetypes and handler.filetypes[filetype] then
    return true
  end

  if extension ~= '' and handler.extensions and handler.extensions[extension] then
    return true
  end

  return false
end

-- Resolve the current buffer to the first configured handler.
local function find_open_handler(bufnr, file)
  for _, handler in ipairs(open_handlers) do
    if handler_matches(handler, bufnr, file) then
      return handler
    end
  end
end

-- macOS-specific launcher. If we ever want non-macOS support, this is the spot
-- to branch on the platform or swap out the implementation.
local function open_with_app(app, file)
  vim.system({ 'open', '-a', app, file }, {}, function(result)
    vim.schedule(function()
      if result.code == 0 then
        vim.notify('Opened in ' .. app .. ': ' .. vim.fn.fnamemodify(file, ':~:.'), vim.log.levels.INFO)
        return
      end

      local stderr = (result.stderr or ''):gsub('%s+$', '')
      local message = stderr ~= '' and stderr or ('Make sure ' .. app .. ' is installed in /Applications')
      vim.notify('Failed to open ' .. app .. ': ' .. message, vim.log.levels.ERROR)
    end)
  end)
end

-- Main flow for :Open:
-- 1. ensure we have a real file
-- 2. find the matching app rule
-- 3. save if needed
-- 4. launch the file in the configured app
local function open_current_buffer()
  local bufnr = vim.api.nvim_get_current_buf()
  local file, file_err = get_current_file(bufnr)

  if not file then
    vim.notify(file_err, vim.log.levels.ERROR)
    return
  end

  local handler = find_open_handler(bufnr, file)
  if not handler then
    vim.notify('No app configured for this buffer', vim.log.levels.ERROR)
    return
  end

  local ok, save_err = save_buffer_if_modified(bufnr)
  if not ok then
    vim.notify('Failed to save buffer before opening ' .. handler.app .. ': ' .. tostring(save_err), vim.log.levels.ERROR)
    return
  end

  open_with_app(handler.app, file)
end

vim.api.nvim_create_user_command('Open', open_current_buffer, {
  desc = 'Open current buffer in its configured app',
})

-- Copy GitHub permalink for current file/line(s)
vim.api.nvim_create_user_command('CopyGitHubPermalink', function(opts)
  local file = vim.fn.expand('%:p')
  local git_root = vim.fn.systemlist('git rev-parse --show-toplevel')[1]
  if vim.v.shell_error ~= 0 or not git_root then
    vim.notify('Not in a git repository', vim.log.levels.ERROR)
    return
  end

  local rel_path = file:sub(#git_root + 2)
  local commit = vim.fn.systemlist('git rev-parse HEAD')[1]
  local remote_url = vim.fn.systemlist('git remote get-url origin')[1]
  if not remote_url then
    vim.notify('No git remote "origin" found', vim.log.levels.ERROR)
    return
  end

  -- Normalize remote URL to GitHub HTTPS
  remote_url = remote_url
      :gsub('git@github.com:', 'https://github.com/')
      :gsub('%.git$', '')

  local line_start = opts.line1
  local line_end = opts.line2
  local line_fragment
  if line_start == line_end then
    line_fragment = '#L' .. line_start
  else
    line_fragment = '#L' .. line_start .. '-L' .. line_end
  end

  local permalink = remote_url .. '/blob/' .. commit .. '/' .. rel_path .. line_fragment
  copy_to_clipboard(permalink)
end, { range = true })

-- Switch to git root or file parent dir
vim.api.nvim_create_user_command('RootDir', function()
  local root = require('lib.util').get_root_dir()

  if root == '' then
    return
  end
  vim.cmd('lcd ' .. root)
end, {})
