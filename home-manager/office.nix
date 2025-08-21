# ~/nix-config/cnd901.nix
{ pkgs, ... }:

{
  home.username = "irteam";
  home.homeDirectory = "/home1/irteam/work/jihoonc";

  home.packages = [
  #   # Packages only for cnd901
  #  pkgs.nodejs
    pkgs.glibcLocalesUtf8 # For locale support
  ];

  To remove locale warning when exiting vim
  home.sessionVariables = {
    LOCALE_ARCHIVE = "${pkgs.glibcLocalesUtf8}/lib/locale/locale-archive";
  };
}
