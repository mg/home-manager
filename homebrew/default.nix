{ inputs, username, ... }:
  # https://github.com/zhaofengli/nix-homebrew
{
  nix-homebrew = {
    enable = true;
    # enableRosetta = true;
    user = username;
    taps = {
      "homebrew/homebrew-core" = inputs.homebrew-core;
      "homebrew/homebrew-bundle" = inputs.homebrew-bundle;
      "homebrew/homebrew-cask" = inputs.homebrew-cask;
    };
    mutableTaps = false;
    # autoMigrate = true; # remember this before first run
    extraEnv = {
      HOMEBREW_NO_ANALYTICS = "1";
    };
  };
}
