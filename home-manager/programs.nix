# https://nix-community.github.io/home-manager/options.xhtml

{ pkgs, ... }:
{
  programs = {
    bat.enable = true;
    bat.config.theme = "TwoDark"; # batextras?

    fzf = {
      enable = true;
      enableZshIntegration = true;
    };
   
    # https://github.com/atuinsh/atuin
    # https://nix-community.github.io/home-manager/options.xhtml#opt-programs.atuin.enable
    atuin = {
      enable = true;
      enableZshIntegration = true;
      flags = [
        "--disable-ctrl-r"            
      ];
    };

    # https://eza.rocks/
    eza = {
      enable = true;
      # git = true;
      icons = true;
    };

    git.enable = true;

    nushell = {
      enable = true;
      configFile.source = dotfiles/nushell/shell.nu;
      envFile.source = dotfiles/nushell/env.nu;
    };

    zoxide = {
      enable = true;
      enableZshIntegration = true;
      enableNushellIntegration = true;
      options = ["--cmd cd"];
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

    #mise = {
    #  enable = true;
    #  enableZshIntegration = true;
    #};

    # https://yazi-rs.github.io/
    yazi = {
      enable = true;
      enableZshIntegration = true;
    };

    #carapace = {
    #  enable = true;
    #  enableZshIntegration = true;
    #};

    # https://xplr.dev/
    xplr.enable = true;
    home-manager.enable = true;
  };
}
