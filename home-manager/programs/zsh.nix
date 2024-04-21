{ pkgs, config, ... }:
{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    enableAutosuggestions = true;
    syntaxHighlighting.enable = true;

    shellAliases = {
      code = "\"/Applications/Visual\ Studio\ Code.app/Contents/Resources/app/bin/code\"";
      nixswitch = "pushd ~/Projects/home-manager; darwin-rebuild switch --flake ~/Projects/home-manager/.#; popd;";
      nixup = "pushd ~/Projects/home-manager; nix flake update; nixswitch; popd;";

      gc = "git checkout $(git branch | fzf)";
      gco = "git checkout $(git branch --remote | fzf)";
      gfl = "git-forgit log";
      gfd = "git-forgit diff";
      gfs = "git-forgit stash_show";
      gfb = "git-forgit blame";
      tokei = "tokei -n dots";
      zj = "zellij";
    };

    initExtra = ''
      source ${pkgs.zsh-fzf-tab}/share/fzf-tab/fzf-tab.plugin.zsh
      if [[ $TERM == "xterm-kitty" ]]
      then
        eval "$(${pkgs.zellij}/bin/zellij setup --generate-auto-start zsh)"
      fi

      export PATH=$PATH:~/opt/flutter/bin

    '';
  };
}
