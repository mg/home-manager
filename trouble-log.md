# Trouble log

## 2025-07-17

### Broken package

Build fails because a package is pulling in a dependency that has been marked as broken.

#### Solution 1 

Configure the flake to allow broken packages to be pulled in.

``` nix
pkgs = import nixpkgs { 
  system = machineConfig.system; 
  config.allowUnfree = true;
  config.allowBroken = true;  # Add this line
};
```

#### Solution 2 

Run the build with trace and let Claude find out which pacakge is pulling in the broken dependency.

```sh 
> darwin-rebuild switch --flake . --show-trace
```

In this instance `harlequin-2.1.2` was pulling in the broken `python3.13-textual-4.0.0` dependency.

### System activation must run as root

Nix-Darwin is changing how system activation is run, it must be run as root now.

### Solution 

```nix
{
  system.primaryUser = "mg";  
  
  system.activationScripts.activateUserSettings.text = ''
    # Run activateSettings as the primary user
    sudo -u ${config.system.primaryUser} /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u
  ''
}
```
