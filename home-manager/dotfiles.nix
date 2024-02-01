{ pkgs, ... }:
{
  home = {
    file.".inputrc".source = ./dotfiles/inputrc;
    file."./.config/git/config".source = ./dotfiles/gitconfig;
    file."./.config/alacritty/alacritty.yml".source = ./dotfiles/alacritty.yml;
    file."./.config/kitty/kitty.conf".text = ''
      ${builtins.readFile ./dotfiles/kitty/kitty.conf} 
      ${builtins.readFile ./dotfiles/kitty/catppuccin-mocha.conf}
    '';
    file."./.config/tig/config".source = ./dotfiles/tigrc;
    file."./.config/helix/config.toml".source = ./dotfiles/helix/config.toml;
    file."./.config/helix/themes/catppuccin-mocha.toml".source = ./dotfiles/helix/catppuccin-mocha-theme.toml;
    file."./.config/starship.toml".source = ./dotfiles/starship/starship.toml;
    file.".jqp.yaml".source = ./dotfiles/jqp.yaml;
    file."./.config/zellij/config.kdl".source = ./dotfiles/zellij.kdl;
    file."./.hammerspoon/init.lua".source = ./dotfiles/hammerspoon/init.lua;
    file."./.hammerspoon/windowmanager.lua".source = ./dotfiles/hammerspoon/windowmanager.lua;
    # home.file.".profile".source = ./dotfiles/zsh/zprofile;
    # home.file.".zshenv".source = ./dotfiles/zsh/zshenv;
    # home.file."./.config/lsd/config.yaml".source = ./dotfiles/lsd.yaml;
    file."./.config/mc/mc.ini".source = ./dotfiles/mc/ini;
    file."./.local/share/mc/skins/catpuccin.ini".source = ./dotfiles/mc/catpuccin.ini;

    # ssh setup
    file.".ssh/config".source = ./dotfiles/ssh/config;
  };
}
