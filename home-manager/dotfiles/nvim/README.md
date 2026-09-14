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

## Python: host vs devc

Launch Neovim **from the project root's direnv-activated shell**. A nonempty
`DEVC_LANG` selects container tooling, including projects using `use local`:

| Tool | Normal project | devc project |
| --- | --- | --- |
| Type/completion LSP | host `ty server` | `devc run basedpyright-langserver --stdio` |
| Lint, format-on-save, import actions | host `ruff server` | `devc run ruff server` |
| Debug adapter | host/Mason `debugpy-adapter` | `devc run python -m debugpy.adapter` |
| Debuggee Python | VIRTUAL_ENV, Conda, `.venv`, `venv`, PATH | guest `.venv`, `venv`, image Python |

The dev image must supply BasedPyright, Ruff, and debugpy (`python-dev` does).
Host-only `behave-lsp` is not enabled in devc sessions. Mason does not auto-install
host debugpy in those sessions. Outside devc, existing host tooling is unchanged.
There is no active Python Conform/nvim-lint setup; formatting uses Ruff's LSP.
Ruff waits for a filename: an unnamed buffer with `:set ft=python` still gets
BasedPyright completion, but Ruff's lint/format support attaches after
`:file scratch.py` or `:write scratch.py`. No save is required just to name it.

Use `devc run uv sync` to create the Linux `.venv`; do not activate it on macOS.
Debugger interpreter detection runs inside the container, so Linux symlinks work.
Set a breakpoint and use `<leader>dc` / F6 to launch the current file. In devc,
DAP forces `internalConsole` (output in the DAP REPL), including for
`.vscode/launch.json`: an integrated terminal would try to launch Linux Python
on the host. Explicit `python`/`pythonPath` in launch.json must be guest paths.

Environment selection is per Neovim session, not automatic `.envrc` evaluation
when opening another project. Restart Neovim from the appropriate project shell
when switching between host and devc projects. Home Manager installs this config
from the Nix store: run `just switch` yourself to apply, or test the source with
`just test-nvim`.

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
