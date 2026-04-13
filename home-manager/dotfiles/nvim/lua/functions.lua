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
