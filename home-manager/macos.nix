# ~/nix-config/macos.nix
{ pkgs, ... }:

{
  home.username = "jihoonc";
  home.homeDirectory = "/Users/jihoonc";

  # Packages only for macOS
  home.packages = [
    pkgs.bash
    pkgs.go
    pkgs.ffmpeg
  ];
}
