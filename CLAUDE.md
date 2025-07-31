# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Common Commands

### Development Commands
- `just switch` - Rebuild and switch to new configuration (requires sudo)
- `just update` - Update flake inputs
- `just clean` - Run garbage collection
- `just inspect` - Inspect system configuration dependencies using nix-tree
- `just test-nvim` - Test neovim configuration in isolated environment
- `just search <package> [limit]` - Search for packages (default limit: 10)
- `just run <package>` - Run package in temporary shell

### Nix Commands
- `nix flake update` - Update all flake inputs
- `sudo darwin-rebuild switch --flake .` - Manual rebuild (same as `just switch`)
- `nix-tree .#darwinConfigurations.L45024.system` - Inspect dependencies
- `nix-collect-garbage -d` - Clean up old generations

## Architecture

This is a **Nix Darwin + Home Manager configuration** for macOS system management.

### Core Structure
- **flake.nix** - Main flake configuration defining inputs and outputs
- **darwin/** - nix-darwin system-level configuration (macOS settings, fonts, services)
- **home-manager/** - User-level configuration (packages, programs, dotfiles)
- **homebrew/** - Homebrew package management integration

### Key Components

#### System Configuration (darwin/)
- **default.nix** - Main system configuration including macOS defaults, keyboard settings, dock preferences
- **homebrew.nix** - Homebrew integration and cask definitions

#### User Configuration (home-manager/)
- **default.nix** - Entry point importing all user modules
- **packages.nix** - CLI tools and development packages
- **programs.nix** - Program configurations (tmux, git, shell tools)
- **programs/** - Specialized program configurations (zsh, tmux, zellij)
- **dotfiles.nix** - Dotfile management and symlinks
- **scripts.nix** - Custom scripts installation to ~/.local/bin
- **session-variables.nix** - Environment variables

#### Machine Configuration
- Target hostname: `L45024`
- User: `mg`
- System: `aarch64-darwin` (Apple Silicon)

### Key Features
- Comprehensive CLI toolset with modern alternatives (eza, bat, ripgrep, etc.)
- AI tools integration (claude-code, aider, ollama)
- Development environments for Elixir, Go, Python, Node.js
- Database tools (DuckDB, PostgreSQL clients)
- Terminal multiplexer setup with tmux
- Dotfiles management for neovim, zsh, and other tools

### Flake Inputs
- nixpkgs (unstable channel)
- home-manager
- nix-darwin
- nix-homebrew with multiple taps

### Testing Changes
After making configuration changes, always run `just switch` to apply them. For neovim config testing, use `just test-nvim` to test in isolation.