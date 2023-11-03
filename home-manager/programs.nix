{ pkgs, ... }:
{
  programs = {
    bat.enable = true;
    bat.config.theme = "TwoDark"; # batextras?

    fzf = {
      enable = true;
      enableZshIntegration = true;
    };

    # https://eza.rocks/
    eza = {
      enable = true;
      git = true;
      enableAliases = true;
      # icons = true;
    };

    git.enable = true;

    zsh = {
      enable = true;
      enableCompletion = true;
      enableAutosuggestions = true;
      syntaxHighlighting.enable = true;
    };

    zsh.shellAliases = { 
      # ls = "eza"; 
      cat = "bat";
      gc = "git checkout $(git branch | fzf)";
      gco = "git checkout $(git branch --remote | fzf)";
      gcb = "git-commit-browser";
      nixswitch = "pushd ~/Projects/home-manager; darwin-rebuild switch --flake ~/Projects/home-manager/.#; popd;";
      nixup = "pushd ~/Projects/home-manager; nix flake update; nixswitch; popd;";
    };

    nushell = {
      enable = true;
      configFile.source = dotfiles/nushell/shell.nu;
      envFile.source = dotfiles/nushell/env.nu;
    };

    # https://starship.rs
    starship = { 
      enable = true;
      enableZshIntegration = true;
      enableNushellIntegration = true;
    };

    # https://direnv.net/
    direnv = {
      enable = true;
      enableZshIntegration = true;
      enableNushellIntegration = true;
      nix-direnv.enable = true;
      config.source = dotfiles/direnv.toml;
    };

    # https://yazi-rs.github.io/
    yazi = { 
      enable = true;
      enableZshIntegration = true;
    };

    # https://xplr.dev/
    xplr.enable = true;
    home-manager.enable = true;
  };
}