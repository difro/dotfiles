# AGENT.md - Dotfiles Configuration Repository

## Build/Test Commands
- **Home Manager (Nix)**: `home-manager switch --flake .#macos` (for macOS) or `home-manager switch --flake .#linux` (for Linux)
- **Update Nix flake**: `nix flake update` (run from home-manager/ directory)
- **Install symlinks**: `./.makesymlinks.sh` (creates symlinks for all dotfiles)
- **Install Homebrew**: `./.installbrew.sh`
- **Install Vim plugins**: `./.installvimplug.sh`

## Architecture & Structure
This is a cross-platform dotfiles repository supporting macOS and Linux environments via Nix Home Manager. Core components:
- **home-manager/**: Declarative package management with flake.nix for different systems (macos/linux/office)
- **nvim/**: Modern Neovim configuration using Lazy.nvim plugin manager with LSP, treesitter, and Go development tools
- **Terminal configs**: ghostty/, wezterm/, alacritty.yml for various terminal emulators
- **Window management**: aerospace/ for macOS tiling window manager, karabiner/ for keyboard customization
- **Shell**: bashrc with custom prompt, aliases, and environment variables; tmux.conf for terminal multiplexing
- **Traditional editor**: vimrc with vim-plug for legacy Vim setup

## Code Style & Conventions
- **Indentation**: Tabs preferred (tabstop=8, shiftwidth=8, noexpandtab in Vim configs)
- **Comments**: Use `#` for shell scripts, `"` for Vim, `--` for Lua, TOML-style for config files
- **Naming**: kebab-case for directories, snake_case for shell functions, descriptive names for configs
- **Theme consistency**: Catppuccin (Mocha/Macchiato) color scheme across all applications
- **File organization**: Group related configs in subdirectories, maintain separate platform-specific configs
