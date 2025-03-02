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
      icons = "auto";
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
      baseIndex = 1;
      plugins = with pkgs; [
        {
          plugin = tmuxPlugins.resurrect;
          extraConfig = ''
            set -g @resurrect-strategy-nvim 'session'
            set -g @resurrect-default-shell "/bin/zsh"
            set -g @resurrect-default-command "/bin/zsh"
            set -g @resurrect-processes 'all'
          '';
        }
        {
          plugin = tmuxPlugins.continuum;
          extraConfig = ''
            set -g @continuum-restore 'on'
         '';
        }
        tmuxPlugins.nord
        {
          plugin = tmuxPlugins.mode-indicator;
          # extraConfig = "set -g status-right '#{status-right} #{tmux_mode_indicator}'";
        } 
        tmuxPlugins.fingers
      ];
      extraConfig = '' 
        # Set new panes to open in current directory
        bind c new-window -c "#{pane_current_path}"
        bind '"' split-window -c "#{pane_current_path}"
        bind % split-window -h -c "#{pane_current_path}"

        # start indexing from 1, not 0. Automatically renumber when closing/creating
        set -g renumber-windows on
        
        set -g default-terminal "screen-256color"
        
        # resize panes key bindings
        bind-key -r -T prefix H resize-pane -L
        bind-key -r -T prefix J resize-pane -D
        bind-key -r -T prefix K resize-pane -U
        bind-key -r -T prefix L resize-pane -R

        # use zsh 
        set-option -g default-shell /bin/zsh
        set -g default-shell /bin/zsh
        set -g default-command /bin/zsh
      '';
    };
    
    # Some plugins to check
    # https://github.com/erikw/tmux-powerline
    # https://github.com/wfxr/tmux-fzf-url
    # https://github.com/sainnhe/tmux-fzf
    # https://github.com/AngryMorrocoy/tmux-neolazygit?tab=readme-ov-file
    # https://github.com/noscript/tmux-mighty-scroll
    # https://github.com/jaclu/tmux-menus

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
