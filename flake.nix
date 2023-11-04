{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    darwin.url = "github:lnl7/nix-darwin";
    darwin.inputs.nixpkgs.follows = "nixpkgs";

    # homebrew
    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";
    nix-homebrew.inputs.nixpkgs.follows = "nixpkgs";
    
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

  outputs = { nixpkgs, darwin, home-manager, ...}@inputs:
    let
      system =  "aarch64-darwin";
      hostname = "mg-m2";
      username = "mg";
      home = "/Users/mg";
      pkgs = import nixpkgs { inherit system; };
    in 
      {
        darwinConfigurations.${hostname}= darwin.lib.darwinSystem {
          inherit system;
          inherit pkgs;

          specialArgs = { inherit inputs hostname username home; };

          modules = [
            ./darwin

            inputs.nix-homebrew.darwinModules.nix-homebrew (import ./homebrew { inherit inputs username; })

            # https://nix-community.github.io/home-manager/index.html#ch-installation
            home-manager.darwinModules.home-manager
            {
              # https://nix-community.github.io/home-manager/options.html
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                users.mg = import ./home-manager { inherit pkgs inputs hostname username home; };
              };
            }
          ];
        };
      };
}