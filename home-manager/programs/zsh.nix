{ pkgs, config, ... }:
{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    shellAliases = {
      gc = "git checkout $(git branch | fzf)";
      gco = "git checkout $(git branch --remote | fzf)";
      gfl = "git-forgit log";
      gfd = "git-forgit diff";
      gfs = "git-forgit stash_show";
      gfb = "git-forgit blame";
      tokei = "tokei -n dots";
    };

    initContent = ''
      source ${pkgs.zsh-fzf-tab}/share/fzf-tab/fzf-tab.plugin.zsh

      export XDG_CONFIG_HOME=~/.config
      export XDG_DATA_HOME=~/.local/share
      export XDG_CACHE_HOME=~/.cache
      export XDG_STATE_HOME=~/.local/state

      # go should go under ~/.local/lib/go
      mkdir -p ~/.local/lib/go
      export GOPATH=~/.local/lib/go
      export PATH=$GOPATH/bin:$PATH

      # rust shold go under ~/.local/lib/cargo
      mkdir -p ~/.local/lib/cargo
      export CARGO_HOME=$HOME/.local/lib/cargo
      export PATH=~/.local/lib/cargo/bin:$PATH

      # dart should go under ~./local/lib/dart
      # flutter should go under ~/.local/lib/flutter
      mkdir -p ~/.local/lib/dart
      export PUB_CACHE=$HOME/.local/lib/dart
      export PATH=~/.local/lib/flutter/bin:~/.local/lib/dart/bin:$PATH

      # bun js should go under ~/.local/lib/bun
      mkdir -p ~/.local/lib/bun
      export BUN_INSTALL=$HOME/.local/lib/bun
      export PATH=~/.local/lib/bun/bin:$PATH

      # uv python should go under ~./local/lib/python
      mkdir -p ~/.local/lib/python
      export PYTHONUSERBASE=$HOME/.local/lib/python/bin
      
      # add my scripts first 
      export PATH=~/.local/bin:$PATH

      export OBSIDIAN_PATH="/Users/mg/Library/Mobile Documents/iCloud~md~obsidian/Documents/obsidian"
      export WOBSIDIAN_PATH="$OBSIDIAN_PATH/work"

      export MANPAGER='nvim +Man!'

      # https://github.com/n1ghtmare/tiny-dc
      dc() {
        local result=$(command tiny-dc "$@")
        [ -n "$result" ] && cd -- "$result"
      }

      # custom python packages go under ~./local/lib/system
      export PYTHONPATH=$HOME/.local/lib/system:$PYTHONPATH
      mkdir -p ~/.local/lib/system 

      # worktree scripts
      wta() {
        # Usage: wta BRANCH [NAME]
        result=$(worktree add "$@")
        echo "$result"
        local cd_cmd=$(echo "$result" | grep "^cd " | tail -1)
        if [[ -n "$cd_cmd" ]]; then
          eval "$cd_cmd"
        fi
      } 

      wtr() {
        worktree remove "$@"
      } 

      wtl() {
        worktree list
      } 

      wts() {
        # Fuzzy switch to another worktree
        result=$(worktree switch)
        echo "$result"
        local cd_cmd=$(echo "$result" | grep "^cd " | tail -1)
        if [[ -n "$cd_cmd" ]]; then
          eval "$cd_cmd"
        fi
      } 
    '';
  };
}
