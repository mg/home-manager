# Nix Darwin Management Commands

# List available commands
default:
  @just --list

# Rebuild and switch to new configuration
switch:
  sudo darwin-rebuild switch --flake .

# Update flake inputs
update:
  nix flake update

# Update nix channel
update-channel:
  nix-channel --update

# Search for package
search package limit="10":
  nix-search -d -m {{limit}} "{{package}}"

# Run grabage collection
clean:
  nix-collect-garbage -d

# Run package in temporary shell
run package:
  -nix-shell -p "{{package}}"
	
# Inspect system configuration dependencies
inspect:
  nix-tree .#darwinConfigurations.L45024.system

# Test neovim configuration 
test-nvim:
  pushd ./home-manager/dotfiles/nvim; export NVIM_APPNAME=nvim-homemanager && nvim; popd
