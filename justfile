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

# Search for packages
search package_name:
    nix-search "{{package_name}}"

# Inspect system configuration dependencies
inspect:
    nix-tree .#darwinConfigurations.L45024.system
