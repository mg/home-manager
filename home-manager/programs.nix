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

    # https://nix-community.github.io/home-manager/options.xhtml#opt-programs.tmux.plugins
    # https://github.com/NixOS/nixpkgs/blob/master/pkgs/misc/tmux-plugins/default.nix
    tmux = {
      enable = true;
      clock24 = true;
      mouse = true;
      prefix = "C-a";
      sensibleOnTop = true;
      escapeTime = 0;
      plugins = with pkgs; [
        tmuxPlugins.cpu
        tmuxPlugins.mode-indicator
        tmuxPlugins.nord
        tmuxPlugins.fingers
      ];
      extraConfig = '' 
        # Set new panes to open in current directory
        bind c new-window -c "#{pane_current_path}"
        bind '"' split-window -c "#{pane_current_path}"
        bind % split-window -h -c "#{pane_current_path}"
      '';
    };

    # https://direnv.net/
    direnv = {
      enable = true;
      enableZshIntegration = true;
      enableNushellIntegration = true;
      nix-direnv.enable = true;
      config.source = dotfiles/direnv.toml;
    };

/*     neovim = {
      enable = true;
      extraLuaPackages = ps: [ ps.magick ];
      extraPackages = ps: [ ps.imagemagick ];
      vimAlias = true;
      vimDiffAlias = true;
      withNodeJs = true;
      withPython3 = true;
      withRuby = true;
    };
 */
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
