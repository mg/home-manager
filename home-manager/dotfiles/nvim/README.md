## ToDo

- [ ] Tree sitter: TS manager, TS query, nvim-treesitter
    - https://www.reddit.com/r/neovim/comments/1sj1ggo/treesitter_without_nvimtreesitter_a_guide/
    https://www.reddit.com/r/neovim/comments/1sdqb2i/treesittermanagernvim_a_lightweight_parser/
- [x] LSP
- [x] Code formatting
- [x] Code completion
- [x] AI for work
- [x] AI for home
- [ ] Typescript / Javascript / GraphQL / CSS / ESLint
- [ ] Dart / Flutter
- [ ] Python
- [ ] Elixir
- [ ] Lua
- [ ] Nix
- [x] Breadcrumb bar
- [x] Status line
- [ ] Git history, blame, status
- [x] LazyGit
- [x] Yazi
- [x] Just runner
- [ ] Oil: git status missing
- [x] Pickers
    - [x] fff
    - [x] snacks
- [x] Which-key
- [x] Message UI
- [ ] Database
- [ ] Jira: https://github.com/emrearmagan/atlas.nvim

https://github.com/saghen/blink.indent
https://github.com/saghen/blink.cmp

## lsp:
- tailwindcss
- eslint
- graphql
- oxfmt

4 LSP configs fail because they require('lspconfig.util') and you don't have nvim-lspconfig loaded
 as a plugin (it's in your lock file but likely not on the runtime path). Commented out eslint,
 graphql, oxfmt, and tailwindcss.

 To fix those properly later, you'd either:
 1. Add nvim-lspconfig to your plugin setup, or
 2. Rewrite those configs to use native vim.fs.find() / root_markers instead of lspconfig.util
