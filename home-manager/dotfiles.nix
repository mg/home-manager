{ pkgs, ... }:
{
  home = {
    file.".inputrc".source = ./dotfiles/inputrc;
    file."./.config/git/config".source = ./dotfiles/gitconfig;
    file."./.config/alacritty/alacritty.yml".source = ./dotfiles/alacritty.yml;
    file."./.config/kitty/kitty.conf".source = ./dotfiles/kitty.conf;
    file."./.config/starship.toml".source = ./dotfiles/starship/starship.toml;
    file."./.config/zellij/config.kdl".source = ./dotfiles/zellij.kdl;
    file."./.hammerspoon/init.lua".source = ./dotfiles/hammerspoon/init.lua;
    file."./.hammerspoon/windowmanager.lua".source = ./dotfiles/hammerspoon/windowmanager.lua;
    # home.file.".profile".source = ./dotfiles/zsh/zprofile;
    # home.file.".zshenv".source = ./dotfiles/zsh/zshenv;
    # home.file."./.config/lsd/config.yaml".source = ./dotfiles/lsd.yaml;

    # ssh setup
    file.".ssh/config".source = ./dotfiles/ssh/config;
  };
}