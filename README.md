
- https://nixos.org/download
- sh <(curl -L https://nixos.org/nix/install) --daemon
- nix-shell -p git
- nix --extra-experimental-features "nix-command flakes" build .#darwinConfigurations.mg-m5.system
- ./result/sw/bin/darwin-rebuild switch --flake .#mg-m5
- sudo darwin-rebuild switch --flake .#mg-m5
- nixup
- nix flake update
- nix-tree .#darwinConfigurations.mg-m5.system

## AeroSpace and SketchyBar

Configured in `darwin/window-manager.nix`, imported by `darwin/default.nix`.
Both are installed through Nix and run as launchd user services; do not also
start them through Homebrew or AeroSpace's own login-item setting.

After running `just switch`:

1. Quit Magnet and disable its launch-at-login setting to avoid competing window managers.
2. Grant **AeroSpace** access in **System Settings → Privacy & Security → Accessibility**.
   If it isn't listed, add the Nix-installed AeroSpace app from `/Applications/Nix Apps`.
3. If macOS requests further permissions, approve them as needed. No SIP changes are required.

SketchyBar shows clickable workspaces 1–9, the active app, and a clock on all
screens. The native menu bar auto-hides; move the pointer to the top to access it.
Workspace highlighting is event-driven with a periodic refresh for service restarts.

All window-manager shortcuts use **Control+Option**, leaving Option+O for Neovim:

| Keys (with Control+Option) | Action |
| --- | --- |
| `h/j/k/l` | Focus left/down/up/right |
| `Shift+h/j/k/l` | Move window left/down/up/right |
| `1`–`9` | Switch workspace |
| `Shift+1`–`9` | Send window to workspace (without following) |
| `Tab` | Previous workspace |
| `Shift+Tab` | Move workspace to next monitor |
| `-` / `=` | Shrink / grow window |
| `/` / `,` | Cycle tiled / accordion layouts |
| `Space` | Toggle floating / tiling |
| `f` | Toggle AeroSpace fullscreen |
| `Enter` | Open/focus Ghostty |
| `Shift+r` | Reload AeroSpace's generated config |

Make configuration changes in Nix and apply with `just switch`; the generated
AeroSpace and SketchyBar configs are read-only files in the Nix store.
