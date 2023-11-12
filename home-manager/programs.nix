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

    # vscode extensions
    vscode = {
      enable = true;
      extensions = with pkgs.vscode-extensions; [
        # flutter support
        dart-code.dart-code
        dart-code.flutter

        # javascript support
        esbenp.prettier-vscode

        # nix support
        jnoortheen.nix-ide
        kamadorueda.alejandra
        arrterian.nix-env-selector
        mkhl.direnv
        # missing: https://marketplace.visualstudio.com/items?itemName=pinage404.nix-extension-pack

        # python support
        ms-toolsai.jupyter
        ms-python.python
        ms-python.vscode-pylance
      ];      
    };
  };
}