{
  pkgs,
  config,
  ...
}: {
  # https://nix-community.github.io/home-manager/options.xhtml#opt-programs.tmux.plugins
  # https://github.com/NixOS/nixpkgs/blob/master/pkgs/misc/tmux-plugins/default.nix
  programs.tmux = {
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
      bind-key r source-file ~/.config/tmux/tmux.conf \; display-message "Config reloaded"
      set -g allow-passthrough on
      set -ga update-environment TERM
      set -ga update-environment TERM_PROGRAM
      set-option -g focus-events on
      set -g extended-keys on
      set -g extended-keys-format csi-u

      # vim mode for copy mode
      setw -g mode-keys vi
      bind-key -T copy-mode-vi 'y' send -X copy-pipe-and-cancel 'pbcopy'

      # session management
      bind-key N command-prompt -p "New session name:" "new-session -s '%%'"
      bind-key S display-popup -E "tmux-session-manage"
      bind-key W display-popup -E "tmux list-windows -F '#I: #W #{?window_active,(active),}' | fzf --reverse | cut -d: -f2 | xargs tmux select-window -t"
      bind-key O switch-client -l
      bind-key Q run-shell '
        OLD_SESSION=$(tmux display-message -p '#S')
        tmux switch-client -l
        tmux kill-session -t "$OLD_SESSION"
      '

      # Set new panes to open in current directory
      bind c new-window -c "#{pane_current_path}"
      bind '"' split-window -c "#{pane_current_path}"
      bind % split-window -h -c "#{pane_current_path}"

      # start indexing from 1, not 0. Automatically renumber when closing/creating
      set -g renumber-windows on

      set -g default-terminal "screen-256color"
      set -g pane-border-style "fg=#3b4252"
      set -g pane-active-border-style "fg=#ffb000"
      set -g pane-border-status off

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

      # Maximize pane size vertically, leaving panes above/below at tmux's minimum height
      bind-key Z run-shell "tmux-pane-vertical-maximize '#{pane_id}'"
      bind -n M-z run-shell "tmux-pane-vertical-maximize '#{pane_id}'"

      # Cycle down through vertical panes, wrapping to the top, and vertically maximize the selected pane
      bind -n M-j run-shell "tmux-pane-cycle-vertical-maximize '#{pane_id}'"

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
        "review" r "new-window -n tuicr -c '#{pane_current_path}' tuicr" \
        "tig" t "new-window -n tig -c '#{pane_current_path}' tig" \
        "gitui" i "new-window -n gitui -c '#{pane_current_path}' gitui" \
        "gitu" u "new-window -n gitu -c '#{pane_current_path}' gitu" \
        "gh-dash" h "new-window -n gh-dash -c '#{pane_current_path}' gh-dash"

      bind-key H new-window -n serpl -c "#{pane_current_path}" "serpl"
      bind-key Y new-window -n yazi -c "#{pane_current_path}" "yazi"
      bind-key M new-window -n glow -c "#{pane_current_path}" "glow -w 180"
      bind-key K new-window -n Keybindings "keyb"

      bind-key A display-menu -T "Select agent" \
        "Claude" c "new-window -n Claude -c '#{pane_current_path}' claude" \
        "Opencode" o "new-window -n Opencode -c '#{pane_current_path}' opencode" \
        "Crush" s "new-window -n Crush -c '#{pane_current_path}' crush" \
        "Aider" a "new-window -n Aider -c '#{pane_current_path}' aider --no-gitignore" \
        "Gemini" g "new-window -n Gemini -c '#{pane_current_path}' gemini" \
        "Codex" x "new-window -n Codex -c '#{pane_current_path}' codex"

      bind-key D display-menu -T "Select db client" \
        "psql" p "new-window -n psql -c '#{pane_current_path}' open-psql" \
        "DuckDB" d "new-window -n DuckDB -c '#{pane_current_path}' open-duckdb" \
        "Rainfrog" r "new-window -n Rainfrog -c '#{pane_current_path}' open-rainfrog"
    '';
  };
}
# Some plugins to check
# https://github.com/erikw/tmux-powerline
# https://github.com/wfxr/tmux-fzf-url
# https://github.com/sainnhe/tmux-fzf
# https://github.com/AngryMorrocoy/tmux-neolazygit?tab=readme-ov-file
# https://github.com/noscript/tmux-mighty-scroll
# https://github.com/jaclu/tmux-menus

