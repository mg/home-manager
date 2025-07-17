
- https://nixos.org/download
- sh <(curl -L https://nixos.org/nix/install) --daemon
- nix-shell -p git
- nix --extra-experimental-features "nix-command flakes" build .#darwinConfigurations.workstation.system
- ./result/sw/bin/darwin-rebbuild switch --flake flake.nix
- sudo darwin-rebuild switch --flake .
- nixup
- nix flake update
- nix-tree .#darwinConfigurations.L45024.system
