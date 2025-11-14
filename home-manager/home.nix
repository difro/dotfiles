# ~/nix-config/home.nix
# { pkgs, masterPkgs, aiToolsPkgs, ... }:
{ pkgs, aiToolsPkgs, ... }:

{

  # This is a mandatory setting.
  home.stateVersion = "24.05";

  # Let Home Manager install and manager itself.
  programs.home-manager.enable = true;

  # List of packages you want on ALL your systems
  home.packages = [
    pkgs.bat
    pkgs.btop
    pkgs.bun
    pkgs.cadaver
    pkgs.claude-code
    pkgs.cursor-cli
    pkgs.curl
    pkgs.delta
    pkgs.dust
    pkgs.eza
    pkgs.fzf
    pkgs.gh
    pkgs.git
    pkgs.htop
    pkgs.jq
    pkgs.lazygit
    pkgs.man-db
    pkgs.man-pages
    pkgs.neofetch
    pkgs.neovim
    pkgs.nodejs_24
    pkgs.qwen-code
    pkgs.ripgrep
    pkgs.tig
    pkgs.tmux
    pkgs.uv
    pkgs.zoxide
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
