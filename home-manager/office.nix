{ pkgs, ... }:

{
  home.username = "irteam";
  home.homeDirectory = "/home1/irteam/work/jihoonc";

  # Packages only for office
  home.packages = [
  #  pkgs.nodejs
    pkgs.glibcLocalesUtf8 # For locale support
  ];

  # To remove locale warning when exiting vim
  home.sessionVariables = {
    LOCALE_ARCHIVE = "${pkgs.glibcLocalesUtf8}/lib/locale/locale-archive";
  };
}
