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
        tmuxPlugins.nord
        {
          plugin = tmuxPlugins.mode-indicator;
          # extraConfig = "set -g status-right '#{status-right} #{tmux_mode_indicator}'";
        } 
        tmuxPlugins.fingers
      ];
      extraConfig = '' 
        set -g allow-passthrough on
        set -ga update-environment TERM
        set -ga update-environment TERM_PROGRAM
        set-option -g focus-events on
        
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

        # navigation
        bind h select-pane -L
        bind j select-pane -D
        bind k select-pane -U
        bind l select-pane -R
        
        # Use cmd + z (Mac) or alt/esc + z (Linux) to maximize pane size vertically
        bind -n M-z if -F '#{==:#{@pane_zoomed},1}' \
        'select-layout "#{@layout_save}"; set -u @layout_save; set -u @pane_zoomed' \
        'set -g @layout_save "#{window_layout}"; set -g @pane_zoomed 1; resize-pane -y 100%'
        
        # Use cmd + x or alt/esc + x (Linux) to maximize pane size horizontally
        bind -n M-x if -F '#{@layout_save}' \
        {run 'tmux select-layout "#{@layout_save}" ; set -up @layout_save'} \
        {set -Fp @layout_save "#{window_layout}" ; run 'tmux resize-pane -x 100%'} 

        # use zsh 
        set-option -g default-shell /bin/zsh
        set -g default-shell /bin/zsh
        set -g default-command /bin/zsh

        # popups
        bind g display-popup -d "#{pane_current_path}" -w 80%  -h 80%  -E "lazygit"
        bind S display-popup -E "tmux list-sessions | sed -E 's/:.*$//' | grep -v \"^$(tmux display-message -p '#S')\$\" | fzf --reverse | xargs tmux switch-client -t"
        bind e display-popup -d "#{pane_current_path}" -w 90% -h 90% -E "yazi"
        bind T display-popup -d "#{pane_current_path}" -w 75% -h 75% -E "zsh"
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
