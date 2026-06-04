{ pkgs, config, ... }:
{
  programs.fish = {
    enable = true;

    shellAliases = {
      gfl = "git-forgit log";
      gfd = "git-forgit diff";
      gfs = "git-forgit stash_show";
      gfb = "git-forgit blame";
      wtr = "worktree remove";
      wtl = "worktree list";
    };

    shellInit = ''
      set -g fish_greeting

      set -gx XDG_CONFIG_HOME "$HOME/.config"
      set -gx XDG_DATA_HOME "$HOME/.local/share"
      set -gx XDG_CACHE_HOME "$HOME/.cache"
      set -gx XDG_STATE_HOME "$HOME/.local/state"
      set -gx XDG_BIN_DIR "$HOME/.local/bin"

      # setup postgres
      fish_add_path -g /opt/homebrew/opt/postgresql@17/bin
      set -gx PGDATA /opt/homebrew/var/postgresql@17

      # go should go under ~/.local/lib/go
      mkdir -p "$HOME/.local/lib/go"
      set -gx GOPATH "$HOME/.local/lib/go"
      fish_add_path -g "$GOPATH/bin"

      # rust should go under ~/.local/lib/cargo
      mkdir -p "$HOME/.local/lib/cargo"
      set -gx CARGO_HOME "$HOME/.local/lib/cargo"
      fish_add_path -g "$CARGO_HOME/bin"

      # dart should go under ~/.local/lib/dart
      # flutter should go under ~/.local/lib/flutter
      mkdir -p "$HOME/.local/lib/dart"
      set -gx PUB_CACHE "$HOME/.local/lib/dart"
      fish_add_path -g "$HOME/.local/lib/flutter/bin"
      fish_add_path -g "$HOME/.local/lib/dart/bin"

      # bun js should go under ~/.local/lib/bun
      mkdir -p "$HOME/.local/lib/bun"
      set -gx BUN_INSTALL "$HOME/.local/lib/bun"
      fish_add_path -g "$BUN_INSTALL/bin"

      # node js should go under ~/.local/lib/node
      mkdir -p "$HOME/.local/lib/node/bin"
      fish_add_path -g "$HOME/.local/lib/node/bin"

      # uv python should go under ~/.local/lib/python
      mkdir -p "$HOME/.local/lib/python"
      set -gx PYTHONUSERBASE "$HOME/.local/lib/python/bin"
      fish_add_path -g "$PYTHONUSERBASE"

      # elixir should go under ~/.local/lib/elixir/bin
      mkdir -p "$HOME/.local/lib/elixir/bin"
      set -gx MIX_ESCRIPTS "$HOME/.local/lib/elixir/bin"
      fish_add_path -g "$MIX_ESCRIPTS"

      # add my scripts first
      fish_add_path -g "$HOME/.local/bin"

      set -gx OBSIDIAN_PATH "/Users/mg/Library/Mobile Documents/iCloud~md~obsidian/Documents/obsidian"
      set -gx WOBSIDIAN_PATH "$OBSIDIAN_PATH/work"

      set -gx MANPAGER "nvim +Man!"

      # tv
      tv init fish | source

      # custom python packages go under ~/.local/lib/system
      mkdir -p "$HOME/.local/lib/system"
      if set -q PYTHONPATH
        set -gx PYTHONPATH "$HOME/.local/lib/system:$PYTHONPATH"
      else
        set -gx PYTHONPATH "$HOME/.local/lib/system"
      end

      # work setup
      test -f "$HOME/Work/.env.fish"; and source "$HOME/Work/.env.fish"
      set -gx OPENCODE_CONFIG_DIR "$HOME/Work/opencode"
      set -gx OPENCODE_EXPERIMENTAL_LSP_TOOL true
    '';

    functions = {
      gc = ''
        set -l branch (git branch --format="%(refname:short)" | fzf)
        test -n "$branch"; and git checkout "$branch"
      '';

      gco = ''
        set -l branch (git branch --remote --format="%(refname:short)" | fzf)
        test -n "$branch"; and git checkout "$branch"
      '';

      dc = ''
        set -l result (command tiny-dc $argv)
        test -n "$result"; and cd -- "$result"
      '';

      wta = ''
        set -l output_file (mktemp)
        worktree add $argv | tee "$output_file"
        set -l cd_cmd (grep '^cd ' "$output_file" | tail -n 1)
        rm -f "$output_file"

        if test -n "$cd_cmd"
          eval "$cd_cmd"
        end
      '';

      wts = ''
        set -l output_file (mktemp)
        worktree switch | tee "$output_file"
        set -l cd_cmd (grep '^cd ' "$output_file" | tail -n 1)
        rm -f "$output_file"

        if test -n "$cd_cmd"
          eval "$cd_cmd"
        end
      '';

      rndpwd = ''
        openssl rand -base64 32 | pbcopy
      '';
    };
  };
}
