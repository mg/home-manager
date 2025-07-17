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

        # vim mode for copy mode 
        setw -g mode-keys vi
        bind-key -T copy-mode-vi 'y' send -X copy-pipe-and-cancel 'pbcopy'

        # session management
        bind-key N command-prompt -p "New session name:" "new-session -s '%%'"

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

        # break pane out of window
        bind-key B break-pane -d 
        bind-key E command-prompt -p "join pane from: " "join-pane -h -s '%%'"

        # tool windows 
        bind-key G display-menu -T "Select git tool" \
          "lazygit" l "new-window -n lazygit -c '#{pane_current_path}' lazygit" \
          "tig" t "new-window -n tig -c '#{pane_current_path}' tig" \
          "gitui" i "new-window -n gitui -c '#{pane_current_path}' gitui" \
          "gitu" u "new-window -n gitu -c '#{pane_current_path}' gitu" \
          "gh-dash" h "new-window -n gh-dash -c '#{pane_current_path}' gh-dash"

        bind-key H new-window -n serpl -c "#{pane_current_path}" "serpl"
        bind-key Y new-window -n yazi -c "#{pane_current_path}" "yazi"
        bind-key M new-window -n glow -c "#{pane_current_path}" "glow"
        bind-key A display-menu -T "Select agent" \
          "Claude" c "new-window -n Claude -c '#{pane_current_path}' claude" \
          "Codex" x "new-window -n Codex -c '#{pane_current_path}' codex" \
          "Gemini" g "new-window -n Gemini -c '#{pane_current_path}' gemini" \
          "OpenCode" o "new-window -n OpenCode -c '#{pane_current_path}' opencode"
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
