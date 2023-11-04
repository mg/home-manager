# https://github.com/zhaofengli/nix-homebrew

{ inputs, username, ... }:
{
  nix-homebrew = {
    enable = true;
    
    # TODO: fails with 'ln /usr/local/bin/brew: No such file or directory"
    # enableRosetta = true;
    
    user = username;
    taps = {
      "homebrew/homebrew-core" = inputs.homebrew-core;
      "homebrew/homebrew-bundle" = inputs.homebrew-bundle;
      "homebrew/homebrew-cask" = inputs.homebrew-cask;
    };
    mutableTaps = false; # do not allow installs outside of nix
    # autoMigrate = true; # remember this before first run
    extraEnv = {
      HOMEBREW_NO_ANALYTICS = "1";
    };
  };
}
