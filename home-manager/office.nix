{
  pkgs,
  # aiToolsPkgs,
  ...
}:

{
  home.username = "irteam";
  home.homeDirectory = "/home1/irteam/work/jihoonc";

  # nixos-render-docs (the manual's manpage builder) uses Python multiprocessing;
  # inside nix-user-chroot the build dir path is long enough that its forkserver
  # socket can exceed the AF_UNIX 107-byte limit.
  manual.manpages.enable = false;

  # Packages only for office
  home.packages = [
    pkgs.bat
    pkgs.bfs
    pkgs.btop
    pkgs.bun
    pkgs.claude-code
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
