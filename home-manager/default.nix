# https://nix-community.github.io/home-manager/
# https://nix-community.github.io/home-manager/options.html

{ username, ... }: 
{
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.mg = {
      home.username = username;
      # home.homeDirectory = "/Users/mg"; # clashes with nix-darwin

      home.stateVersion = "23.05";
      nixpkgs.config.allowUnfree = true;

      imports = [
        ./packages.nix
        ./programs.nix
        ./session-variables.nix
        ./dotfiles.nix
        ./zellij.nix
      ];
    };
  };
}