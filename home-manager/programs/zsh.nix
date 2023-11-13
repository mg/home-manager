{pkgs, config, ...}:
{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    enableAutosuggestions = true;
    syntaxHighlighting.enable = true;

    shellAliases = { 
      gc = "git checkout $(git branch | fzf)";
      gco = "git checkout $(git branch --remote | fzf)";
      gcb = "git-commit-browser";
      nixswitch = "pushd ~/Projects/home-manager; darwin-rebuild switch --flake ~/Projects/home-manager/.#; popd;";
      nixup = "pushd ~/Projects/home-manager; nix flake update; nixswitch; popd;";
    };

    initExtra = ''
      source ${pkgs.zsh-fzf-tab}/share/fzf-tab/fzf-tab.plugin.zsh
      if [[ $TERM == "xterm-kitty" ]]
      then
        eval "$(${pkgs.zellij}/bin/zellij setup --generate-auto-start zsh)"
      fi
    '';
  };
}