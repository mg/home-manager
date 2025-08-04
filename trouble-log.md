# Trouble log

## 2025-08-04

### Problem

Version 1.3.2 of `superfile` is not building because some tests are failing. Version `1.3.3` is out but not yet in the `nix` package repository.

### Solution

Since it is just failing tests and the binary works, I can disable the test for now inside `home-manager/home-manager/package.nix`:

```nix
    (superfile.overrideAttrs (oldAttrs: {
      doCheck = false;
    }))
```

## 2025-07-20

### Problem

`elixir-ls` crashes on startup. At first it was because it could not find sources for Elixir standard library (https://github.com/NixOS/nixpkgs/issues/422529) but after some removals and reinstalles it morphed into not installing correctly because it expected the config directory to be in the wrong place (under `mason/packages`, not `mason/packages/elixir-ls`).

### Solution

Since the `elixir-ls` plugin needs to be compiled, and I only had Elixir installd in a `nix-shell`, it could not compile. So step one was to globally install `elixir` and `erlang` and stop installing it through `shell.nix`.

Step two was to stop using `Mason` to install it and to it manually:

```sh 
# Remove the broken Mason installation
rm -rf ~/.local/share/nvim/mason/packages/elixir-ls

# Create a proper elixir-ls installation in a different location
mkdir -p ~/.local/share/elixir-ls
cd ~/.local/share/elixir-ls
```

Install ElixirLS from git
``` sh

# Clone and build elixir-ls properly (from your Nix shell)
git clone https://github.com/elixir-lsp/elixir-ls.git .
mix deps.get
mix compile
MIX_ENV=prod mix elixir_ls.release
```

Configure manually in neovim (not via Mason)
```lua
require('lspconfig').elixirls.setup{
  cmd = { os.getenv("HOME") .. "/.local/share/elixir-ls/release/language_server.sh" },
}
```

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
