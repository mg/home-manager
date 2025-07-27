{...}: {
  home = {
    file.".inputrc".source = ./dotfiles/inputrc;
    file."./.config/git/config".source = ./dotfiles/gitconfig;
    # file."./.config/kitty/kitty.conf".text = ''
    #   ${builtins.readFile ./dotfiles/kitty/kitty.conf}
    #   ${builtins.readFile ./dotfiles/kitty/catppuccin-mocha.conf}
    # '';
    file."./.config/nvim" = {
      source = ./dotfiles/nvim;
      recursive = true;
    };
    # can seem to get this to work, create the symlink manually for now
    # file.".config/nvim-homemanager".source = "/home/mg/Projects/home-manager/home-manager/dotfiles/nvim";
    file."./.config/ghostty/config".source = ./dotfiles/ghostty;

    file."./.config/tig/config".source = ./dotfiles/tigrc;
    file."./.config/gh-dash/config.yml".source = ./dotfiles/gh-dash.yml;
    
    # keyb not available in nix yet
    # https://github.com/NixOS/nixpkgs/blob/master/CONTRIBUTING.md
    # install via go to GOPATH
    # go install github.com/kencx/keyb@latest
    file."./.config/keyb/keyb.yml".source = ./dotfiles/keyb.yml;

    file."./.config/helix/config.toml".source = ./dotfiles/helix/config.toml;
    file."./.config/helix/themes/catppuccin-mocha.toml".source = ./dotfiles/helix/catppuccin-mocha-theme.toml;
    file."./.config/starship.toml".source = ./dotfiles/starship/starship.toml;
    file.".jqp.yaml".source = ./dotfiles/jqp.yaml;
    file."./.hammerspoon/init.lua".source = ./dotfiles/hammerspoon/init.lua;
    # file."./.hammerspoon/windowmanager.lua".source = ./dotfiles/hammerspoon/windowmanager.lua;
    # home.file."./.config/lsd/config.yaml".source = ./dotfiles/lsd.yaml;
    file."./.config/mc/mc.ini".source = ./dotfiles/mc/ini;
    file."./.local/share/mc/skins/catpuccin.ini".source = ./dotfiles/mc/catpuccin.ini;
    file."./.config/zed/settings.json".source = ./dotfiles/zed/settings.json;

    # ssh setup
    file.".ssh/config".source = ./dotfiles/ssh/config;
  };
}
