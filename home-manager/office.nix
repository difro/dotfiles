{
  pkgs,
  # aiToolsPkgs,
  ...
}:

{
  home.username = "irteam";
  home.homeDirectory = "/home1/irteam/work/jihoonc";

  # Packages only for office
  home.packages = [
    # pkgs.nodejs
    # pkgs.asciinema
    # pkgs.asciinema-agg
    # pkgs.claude-code-bin
    pkgs.bat
    pkgs.bfs
    pkgs.btop
    pkgs.bun
    pkgs.codex
    pkgs.curl
    pkgs.delta
    pkgs.dust
    pkgs.eza
    pkgs.fd
    pkgs.fzf
    pkgs.gh
    pkgs.git
    pkgs.glibcLocalesUtf8 # For locale support
    pkgs.golangci-lint
    pkgs.htop
    pkgs.jq
    pkgs.lazygit
    pkgs.luajitPackages.tree-sitter-cli
    pkgs.natscli
    pkgs.neovim
    pkgs.nodejs_24
    pkgs.ripgrep
    pkgs.tmux
    pkgs.ty
    pkgs.ugrep
    pkgs.uv
    pkgs.zellij
    pkgs.zoxide
    # aiToolsPkgs.qwen-code
    # aiToolsPkgs.antigravity-cli
  ];

  # To remove locale warning when exiting vim
  home.sessionVariables = {
    LOCALE_ARCHIVE = "${pkgs.glibcLocalesUtf8}/lib/locale/locale-archive";
    LC_ALL = "en_US.UTF-8";
    LANG = "en_US.UTF-8";
  };
}
