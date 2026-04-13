vim.opt.completeopt =
"menuone,noinsert,popup,fuzzy"                       -- Ensures the menu appears even for a single match and uses the native popup window.
-- vim.o.autocomplete = true                           -- Disabled: interferes with LSP completion autotrigger

vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("lsp_completion", { clear = true }),
  callback = function(args)
    local client_id = args.data.client_id
    if not client_id then
      return
    end

    local client = vim.lsp.get_client_by_id(client_id)
    if client and client:supports_method("textDocument/completion") then
      -- Enable native LSP completion for this client + buffer
      vim.schedule(function()
        vim.lsp.completion.enable(true, client_id, args.buf, {
          autotrigger = true,
        })
      end)
    end

    if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_inlineCompletion, args.buf) then
      vim.lsp.inline_completion.enable(true, { bufnr = args.buf })
      vim.keymap.set("i", "<C-f>", vim.lsp.inline_completion.get,
        { buffer = args.buf, desc = "Trigger inline completion" })
      vim.keymap.set("i", "<C-g>", function() vim.lsp.inline_completion.select({ count = 1 }) end,
        { buffer = args.buf, desc = "Next inline completion" })
    end

    if client and client:supports_method("textDocument/formatting") then
      vim.api.nvim_create_autocmd("BufWritePre", {
        group = vim.api.nvim_create_augroup("lsp_format." .. args.buf, { clear = true }),
        buffer = args.buf,
        callback = function()
          if vim.bo[args.buf].buftype ~= "" then return end
          vim.lsp.buf.format({ bufnr = args.buf, id = client_id, timeout_ms = 3000 })
        end,
      })
    end

    if client and client:supports_method("textDocument/documentSymbol") then
      -- LSP symbol kind icons
      local kind_icons = {
        [1] = " ", -- File
        [2] = " ", -- Module
        [3] = " ", -- Namespace
        [4] = " ", -- Package
        [5] = " ", -- Class
        [6] = " ", -- Method
        [7] = " ", -- Property
        [8] = "料 ", -- Field
        [9] = " ", -- Constructor
        [10] = " ", -- Enum
        [11] = " ", -- Interface
        [12] = "󰊕 ", -- Function
        [13] = " ", -- Variable
        [14] = " ", -- Constant
        [15] = "令 ", -- String
        [16] = "󰎠 ", -- Number
        [17] = "◩ ", -- Boolean
        [18] = " ", -- Array
        [19] = " ", -- Object
        [20] = " ", -- Key
        [21] = "󰟢 ", -- Null
        [22] = " ", -- EnumMember
        [23] = " ", -- Struct
        [24] = " ", -- Event
        [25] = " ", -- Operator
        [26] = " ", -- TypeParameter
      }
      local sep = " %#WinBarSep#>%* "

      -- Define winbar highlight groups
      vim.api.nvim_set_hl(0, "WinBarPath", { link = "Comment" })
      vim.api.nvim_set_hl(0, "WinBarFile", { bold = true })
      vim.api.nvim_set_hl(0, "WinBarSep", { link = "NonText" })
      vim.api.nvim_set_hl(0, "WinBarContext", { link = "Function" })
      vim.api.nvim_set_hl(0, "WinBarIcon", { link = "Type" })

      -- Build winbar with file path and LSP symbol context
      local lsp_buf = args.buf
      local function update_winbar()
        if not vim.api.nvim_buf_is_valid(lsp_buf) then return end
        local wins = vim.fn.win_findbuf(lsp_buf)
        if #wins == 0 then return end
        local win = wins[1]
        local params = vim.lsp.util.make_position_params(win, client.offset_encoding)
        client:request("textDocument/documentSymbol", params, function(err, result)
          if err or not result then return end
          if not vim.api.nvim_buf_is_valid(lsp_buf) then return end
          local ok, cursor = pcall(vim.api.nvim_win_get_cursor, win)
          if not ok then return end
          local row = cursor[1] - 1
          local breadcrumbs = {}
          local function walk(symbols)
            for _, sym in ipairs(symbols) do
              local range = sym.range or sym.location and sym.location.range
              if range and row >= range.start.line and row <= range["end"].line then
                local icon = kind_icons[sym.kind] or ""
                table.insert(breadcrumbs, { icon = icon, name = sym.name })
                if sym.children then walk(sym.children) end
                return
              end
            end
          end
          walk(result)
          local path = vim.api.nvim_buf_get_name(lsp_buf)
          path = vim.fn.fnamemodify(path, ":.")
          local dir = vim.fn.fnamemodify(path, ":h")
          local fname = vim.fn.fnamemodify(path, ":t")
          local icon, icon_hl = require("nvim-web-devicons").get_icon(fname, nil, { default = true })
          local bar = "%#" .. (icon_hl or "WinBarIcon") .. "#" .. icon .. "%* "
          if dir ~= "." then
            bar = bar .. "%#WinBarPath#" .. dir .. "/%*"
          end
          bar = bar .. "%#WinBarFile#" .. fname .. "%*"
          if #breadcrumbs > 0 then
            for _, crumb in ipairs(breadcrumbs) do
              bar = bar .. sep .. "%#WinBarIcon#" .. crumb.icon .. "%*%#WinBarContext#" .. crumb.name .. "%*"
            end
          end
          if vim.api.nvim_win_is_valid(win) then
            vim.wo[win].winbar = bar
          end
        end, lsp_buf)
      end
      vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
        buffer = lsp_buf,
        callback = update_winbar,
      })
      update_winbar()
    end

    -- LSP keymaps (buffer-local)
    local buf = args.buf
    local map = function(mode, lhs, rhs, desc)
      vim.keymap.set(mode, lhs, rhs, { buffer = buf, desc = desc })
    end
    map("n", "<leader>rn", vim.lsp.buf.rename, "[R]e[n]ame")
    map({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, "[C]ode [A]ction")
    map("i", "<C-s>", vim.lsp.buf.signature_help, "Signature Help")
  end,
})

local function is_work_project()
  local cwd = vim.fn.getcwd()
  local work_dir = vim.fn.expand("~/Work")
  return cwd:sub(1, #work_dir) == work_dir
end

local lsp_servers = {
  'ast_grep',
  'awk',
  'bashls',
  'dartls',
  'docker_language_server',
  -- 'eslint',      -- requires lspconfig.util
  'expert',
  'fish',
  -- 'graphql',     -- requires lspconfig.util
  'html',
  'json',
  'just',
  'lua',
  'markdown-oxide',
  'nixd',
  -- 'oxfmt',       -- requires lspconfig.util
  'oxlint',
  'postgres',
  'ruff',
  'svelte',
  -- 'tailwindcss', -- requires lspconfig.util
  'ts_ls',
  'ty',
  'zls',
}

if is_work_project() then
  table.insert(lsp_servers, 'copilot')
end

vim.lsp.enable(lsp_servers)
