{ pkgs, homebrew-core, homebrew-cask, ... }: {
  # https://github.com/zhaofengli/nix-homebrew
  nix-homebrew.darwinModules.nix-homebrew
  {
    nix-homebrew = {
      enable = true;
      enableRosetta = true;
      user = "mg";
      taps = {
        "homebrew/homebrew-core" = homebrew-core;
        "homebrew/homebrew-cask" = homebrew-cask;
      };
      # With mutableTaps disabled, taps can no longer be added imperatively with `brew tap`.
      mutableTaps = false;
    }
  }
}
