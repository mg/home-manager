{ pkgs, config, ... }:
{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    shellAliases = {
      nixswitch = "pushd ~/Projects/home-manager; sudo darwin-rebuild switch --flake ~/Projects/home-manager/.#; popd;";
      nixup = "pushd ~/Projects/home-manager; nix flake update; nixswitch; popd;";
      nixclean = "nix-collect-garbage";

      gc = "git checkout $(git branch | fzf)";
      gco = "git checkout $(git branch --remote | fzf)";
      gfl = "git-forgit log";
      gfd = "git-forgit diff";
      gfs = "git-forgit stash_show";
      gfb = "git-forgit blame";
      tokei = "tokei -n dots";
      # zj = "zellij";
    };

    initContent = ''
      source ${pkgs.zsh-fzf-tab}/share/fzf-tab/fzf-tab.plugin.zsh

      export PATH=$PATH:~/opt/flutter/bin
      export OBSIDIAN_PATH="/Users/mg/Library/Mobile Documents/iCloud~md~obsidian/Documents/obsidian"
      export WOBSIDIAN_PATH="$OBSIDIAN_PATH/work"

      export MANPAGER='nvim +Man!'
    '';
  };
}
