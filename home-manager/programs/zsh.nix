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

      # go should go under ~/.local/lib/go
      # flutter should go under ~/.local/lib/flutter
      mkdir -p ~/.local/lib/go
      export GOPATH=~/.local/lib/go
      export PATH=~/.local/bin:~/.local/lib/flutter/bin:$GOPATH/bin:$PATH

      export OBSIDIAN_PATH="/Users/mg/Library/Mobile Documents/iCloud~md~obsidian/Documents/obsidian"
      export WOBSIDIAN_PATH="$OBSIDIAN_PATH/work"

      export MANPAGER='nvim +Man!'
    '';
  };
}
