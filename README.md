
- https://nixos.org/download
- sh <(curl -L https://nixos.org/nix/install) --daemon
- nix-shell -p git
- nix --extra-experimental-features "nix-command flakes" build .#darwinConfigurations.mg-m5.system
- ./result/sw/bin/darwin-rebuild switch --flake .#mg-m5
- sudo darwin-rebuild switch --flake .#mg-m5
- nixup
- nix flake update
- nix-tree .#darwinConfigurations.mg-m5.system
