# https://github.com/zhaofengli/nix-homebrew

{ inputs, userConfig, ... }:
{
  nix-homebrew = {
    enable = true;
    
    # TODO: fails with 'ln /usr/local/bin/brew: No such file or directory"
    # enableRosetta = true;
    
    user = userConfig.username;
    taps = {
      "homebrew/homebrew-core" = inputs.homebrew-core;
      "homebrew/homebrew-bundle" = inputs.homebrew-bundle; # https://github.com/zhaofengli/nix-homebrew/issues/9#issuecomment-1774684583
      "homebrew/homebrew-cask" = inputs.homebrew-cask;
    };
    mutableTaps = false; # do not allow installs outside of nix
    # autoMigrate = true; # remember this before first run
    extraEnv = {
      HOMEBREW_NO_ANALYTICS = "1";
    };
  };
}
