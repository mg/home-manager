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
search package:
  nix-search -d -m 10 "{{package}}"

# Run grabage collection
clean:
  nix-collect-garbage 

# Run package in temporary shell
run package:
  -nix-shell -p "{{package}}"
	
# Inspect system configuration dependencies
inspect:
  nix-tree .#darwinConfigurations.L45024.system
