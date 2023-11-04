{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    darwin = {
      url = "github:lnl7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # homebrew
    nix-homebrew = {
      url = "github:zhaofengli-wip/nix-homebrew";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    };

    homebrew-bundle = {
      url = "github:homebrew/homebrew-bundle";
      flake = false;
    };

    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    };
  };

  outputs = { nixpkgs, darwin, home-manager, nix-homebrew, ...}@inputs:
    let
      machineConfig = {
        system =  "aarch64-darwin";
        hostname = "mg-m2";
        username = "mg";
        home = "/Users/mg";
        homeManager.stateVersion = "23.05";
      };
      pkgs = import nixpkgs { system = machineConfig.system; config.allowUnfree = true; };
    in 
      {
        darwinConfigurations.${machineConfig.hostname}= darwin.lib.darwinSystem {
          system = machineConfig.system;
          inherit pkgs;
          specialArgs = { inherit inputs machineConfig; };

          modules = [
            ./darwin
            nix-homebrew.darwinModules.nix-homebrew (import ./homebrew)
            home-manager.darwinModules.home-manager (import ./home-manager)
          ];
        };
      };
}