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
    pkgs.curl
    pkgs.delta
    pkgs.dust
    pkgs.eza
    pkgs.fzf
    pkgs.gh
    pkgs.gh-dash
    pkgs.git
    pkgs.htop
    pkgs.jq
    pkgs.lazygit
    pkgs.man-db
    pkgs.man-pages
    pkgs.natscli
    pkgs.neovim
    pkgs.nodejs_24
    pkgs.opencode
    # pkgs.qwen-code  # TODO: nixpkgs upstream npmDepsHash 문제로 임시 비활성화
    pkgs.ripgrep
    pkgs.tmux
    pkgs.ty
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
