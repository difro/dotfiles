{ pkgs, aiToolsPkgs, ... }:

{
  home.username = "irteam";
  home.homeDirectory = "/home1/irteam/work/jihoonc";

  # Packages only for office
  home.packages = [
    # pkgs.nodejs
    # pkgs.asciinema
    # pkgs.asciinema-agg
    # pkgs.claude-code-bin
    pkgs.bfs
    pkgs.glibcLocalesUtf8 # For locale support
    pkgs.ugrep
    pkgs.codex
    # aiToolsPkgs.qwen-code
  ];

  # To remove locale warning when exiting vim
  home.sessionVariables = {
    LOCALE_ARCHIVE = "${pkgs.glibcLocalesUtf8}/lib/locale/locale-archive";
    LC_ALL = "en_US.UTF-8";
    LANG = "en_US.UTF-8";
  };
}
