# https://nix-community.github.io/home-manager/
# https://nix-community.github.io/home-manager/options.html

{ userConfig, ... }: 
{
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.${userConfig.username} = {
      home.username = userConfig.username;
      # home.homeDirectory = home; # clashes with nix-darwin

      home.stateVersion = userConfig.homeManager.stateVersion;

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