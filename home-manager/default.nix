# https://nix-community.github.io/home-manager/
# https://nix-community.github.io/home-manager/options.html

{ username, ... }: 
{
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.${username} = {
      home.username = username;
      # home.homeDirectory = home; # clashes with nix-darwin

      home.stateVersion = "23.05";

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