# ~/.config/nix-darwin/darwin-configuration.nix
{ config, pkgs, ... }:

{
  system.stateVersion = 4;

  system.primaryUser = "jihoonc";

  nix.enable = false;

  # --- Homebrew Configuration ---
  homebrew = {
    enable = true;
    onActivation.cleanup = "zap";
    taps = [];
    brews = [
      "borders"
    ];
    casks = [
      "nikitabobko/tap/aerospace"
    ];
  };
}
