return { -- LSP Configuration & Plugins
  "neovim/nvim-lspconfig",
  dependencies = {
    -- Automatically install LSPs and related tools to stdpath for Neovim
    { "williamboman/mason.nvim", config = true }, -- NOTE: Must be loaded before dependants
    "williamboman/mason-lspconfig.nvim",
    "WhoIsSethDaniel/mason-tool-installer.nvim",

    -- Useful status updates for LSP.
    { "j-hui/fidget.nvim", opts = {} },

    -- `neodev` configures Lua LSP for your Neovim config, runtime and plugins
    -- used for completion, annotations and signatures of Neovim apis
    { "folke/neodev.nvim", opts = {} },
  },
  config = function()
    --  This function gets run when an LSP attaches to a particular buffer.
    vim.api.nvim_create_autocmd("LspAttach", {
      group = vim.api.nvim_create_augroup("kickstart-lsp-attach", { clear = true }),
      callback = function(event)
        local map = function(keys, func, desc)
          vim.keymap.set("n", keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
        end

        map("gd", require("telescope.builtin").lsp_definitions, "[G]oto [D]efinition")
        map("gr", require("telescope.builtin").lsp_references, "[G]oto [R]eferences")
        map("gI", require("telescope.builtin").lsp_implementations, "[G]oto [I]mplementation")
        map("<leader>D", require("telescope.builtin").lsp_type_definitions, "Type [D]efinition")
        map("<leader>ds", require("telescope.builtin").lsp_document_symbols, "[D]ocument [S]ymbols")
        map(
          "<leader>ws",
          require("telescope.builtin").lsp_dynamic_workspace_symbols,
          "[W]orkspace [S]ymbols"
        )
        map("<leader>rn", vim.lsp.buf.rename, "[R]e[n]ame")
        map("<leader>ca", vim.lsp.buf.code_action, "[C]ode [A]ction")
        map("K", vim.lsp.buf.hover, "Hover Documentation")
        map("gD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")

        -- Highlight references of the word under cursor
        local client = vim.lsp.get_client_by_id(event.data.client_id)
        if client and client.server_capabilities.documentHighlightProvider then
          local highlight_augroup =
            vim.api.nvim_create_augroup("kickstart-lsp-highlight", { clear = false })
          vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
            buffer = event.buf,
            group = highlight_augroup,
            callback = vim.lsp.buf.document_highlight,
          })

          vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
            buffer = event.buf,
            group = highlight_augroup,
            callback = vim.lsp.buf.clear_references,
          })

          vim.api.nvim_create_autocmd("LspDetach", {
            group = vim.api.nvim_create_augroup("kickstart-lsp-detach", { clear = true }),
            callback = function(event2)
              vim.lsp.buf.clear_references()
              vim.api.nvim_clear_autocmds({ group = "kickstart-lsp-highlight", buffer = event2.buf })
            end,
          })
        end

        if client and client.server_capabilities.inlayHintProvider and vim.lsp.inlay_hint then
          map("<leader>th", function()
            vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({}))
          end, "[T]oggle Inlay [H]ints")
        end
      end,
    })

    -- Broadcast cmp_nvim_lsp capabilities to all servers
    local capabilities = vim.lsp.protocol.make_client_capabilities()
    capabilities =
      vim.tbl_deep_extend("force", capabilities, require("cmp_nvim_lsp").default_capabilities())
    vim.lsp.config("*", { capabilities = capabilities })

    -- Server-specific overrides (merged on top of nvim-lspconfig defaults)
    vim.lsp.config("lua_ls", {
      settings = {
        Lua = {
          completion = {
            callSnippet = "Replace",
          },
          -- diagnostics = { disable = { 'missing-fields' } },
        },
      },
    })

    vim.lsp.config("tailwindcss", {
      settings = {
        tailwindCSS = {
          experimental = {
            classRegex = {
              'class[:]\\s*"([^"]*)"',
            },
          },
        },
      },
    })

    vim.lsp.config("pylsp", {
      settings = {
        pylsp = {
          plugins = {
            pylint = { enabled = false },
            pyflakes = { enabled = false },
            pycodestyle = { enabled = false },
            black = { enabled = false },
            autopep8 = { enabled = false },
            yapf = { enabled = false },
            pylsp_mypy = { enabled = false },
            pylsp_black = { enabled = false },
            pylsp_isort = { enabled = false },
            mccabe = { enabled = false },

            jedi_completion = { fuzzy = true },
          },
        },
      },
    })

    -- nixd (not in mason)
    vim.lsp.config("nixd", {
      cmd = { "nixd" },
      filetypes = { "nix" },
      root_markers = { "flake.nix", ".git" },
      settings = {
        nixd = {
          nixpkgs = {
            expr = "import <nixpkgs>{ }",
          },
          formatting = {
            command = { "alejandra" },
          },
        },
      },
    })
    vim.lsp.enable("nixd")

    -- expert (not in mason)
    vim.lsp.config("expert", {
      cmd = { "expert", "--stdio" },
      root_markers = { "mix.exs", ".git" },
      filetypes = { "elixir", "eelixir", "heex" },
    })
    vim.lsp.enable("expert")

    -- Mason: install servers and tools
    require("mason").setup()

    require("mason-tool-installer").setup({
      ensure_installed = {
        -- LSP servers
        "gopls",
        "ts_ls",
        "lua_ls",
        "tailwindcss",
        "ruff",
        "pylsp",
        -- Formatters and linters (used by conform.nvim / nvim-lint, not LSP)
        "eslint_d",
        "prettierd",
        "stylua",
      },
    })

    -- mason-lspconfig auto-enables installed servers via vim.lsp.enable()
    require("mason-lspconfig").setup({
      automatic_enable = {
        exclude = { "stylua" },
      },
    })
  end,
}
