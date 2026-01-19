# ~/.config/nix-darwin/darwin-configuration.nix
{ config, pkgs, ... }:

{
  system.stateVersion = 4;

  system.primaryUser = "jihoonc";

  system.defaults.trackpad = {
    Clicking = true; # enable tap to click
  };

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
        "steipete/tap" # for codexbar
    ];
    brews = [
      "borders"
    ];
    casks = [
      "aerospace"
      "alfred"
      "bitwarden"
      "brave-browser"
      "calibre"
      "choosy"
      "claude-code"
      "codexbar"
      "container"
      "font-comic-mono"
      "font-d2coding"
      "ghostty"
      "heynote"
      "input-source-pro"
      "itsycal"
      "jordanbaird-ice@beta"
      "scroll-reverser"
      "stats"
      "ticktick"
      "zoom"
    ];
  };
}
