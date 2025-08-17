# ~/nix-config/macos.nix
{ pkgs, ... }:

{
  home.username = "jihoonc";
  home.homeDirectory = "/Users/jihoonc";

  home.packages = [
    pkgs.ffmpeg
  #   # Packages only for macOS
  #   pkgs.rectangle # A window manager for macOS
  #   pkgs.sketchybar
  ];
}
