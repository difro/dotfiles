# ~/nix-config/cnd901.nix
{ pkgs, ... }:

{
  home.username = "irteam";
  home.homeDirectory = "/home1/irteam/work/jihoonc";

  home.packages = [
  #   # Packages only for cnd901
  #  pkgs.nodejs
  ];
}
