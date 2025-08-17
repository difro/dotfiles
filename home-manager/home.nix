# ~/nix-config/home.nix
{ pkgs, nix-ai-tools, ... }:

{

  # This is a mandatory setting.
  home.stateVersion = "24.05";

  # Let Home Manager install and manager itself.
  programs.home-manager.enable = true;

  # List of packages you want on ALL your systems
  home.packages = [
    pkgs.git
    pkgs.man-db
    pkgs.man-pages
    pkgs.ripgrep
    pkgs.htop
    pkgs.neovim
    pkgs.uv
    pkgs.codex
    pkgs.go
    pkgs.curl
    pkgs.tmux
    pkgs.jq
    pkgs.fzf
    pkgs.nodejs
    pkgs.gh
    pkgs.delta
    pkgs.cadaver
    pkgs.btop
    pkgs.bat
    pkgs.neofetch
    nix-ai-tools.packages.${pkgs.system}.opencode
    nix-ai-tools.packages.${pkgs.system}.qwen-code
  ];

  nixpkgs.config.allowUnfree = true; # Allow unfree packages
  nixpkgs.config.allowUnsupportedSystem = true; # Allow unsupported systems

  # Example: Manage a dotfile declaratively
  # home.file.".gitconfig".text = ''
  #   [user]
  #     name = Your Name
  #     email = your.email@example.com
  # '';
  #
  # # Configure your shell
  # programs.zsh = {
  #   enable = true;
  #   oh-my-zsh.enable = true;
  # };
}
