# ~/.config/nix-darwin/darwin-configuration.nix
{ config, pkgs, ... }:

{
  system.stateVersion = 4;

  system.primaryUser = "jihoonc";

  nix.enable = false;

  # --- Homebrew Configuration ---
  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = true;
      cleanup = "zap";
      upgrade = true;
    };
    taps = [
    	"FelixKratz/formulae" # for jankyborders
        "nikitabobko/tap" # for aerospace
    ];
    brews = [
      "borders"
      "podman"
    ];
    casks = [
      "aerospace"
      "alfred"
      "bitwarden"
      "brave-browser"
      "calibre"
      "choosy"
      "font-comic-mono"
      "font-d2coding"
      "ghostty"
      "heynote"
      "input-source-pro"
      "itsycal"
      "jordanbaird-ice"
      "podman-desktop"
      "stats"
      "ticktick"
      "zoom"
    ];
  };
}
