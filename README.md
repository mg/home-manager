- https://nixos.org/download
- sh <(curl -L https://nixos.org/nix/install) --daemon
- nix-shell -p git
- nix --extra-experimental-features "nix-command flakes" build .#darwinConfigurations.workstation.system
- ./result/sw/bin/darwin-rebbuild switch --flake flake.nix
- darwin-rebuild switch --flake flake.nix
- nixup
- nixswitch


## Examples
https://github.com/zmre/mac-nix-simple-example
