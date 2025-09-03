# ~/.config/nix-darwin/flake.nix
# run with sudo nix run nix-darwin -- switch --flake .#mac
{
  description = "My Nix-Darwin Flake Configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, nix-darwin,  ... }@inputs: {
    # Replace "your-hostname" with the output of the `hostname` command
    darwinConfigurations."mac" = nix-darwin.lib.darwinSystem {
      # For Apple Silicon, use "aarch64-darwin". For Intel, use "x86_64-darwin".
      system = "aarch64-darwin"; 
      specialArgs = { inherit inputs; }; # Pass inputs to other modules
      modules = [
        # Your main configuration file
        ./darwin-configuration.nix

      ];
    };
  };
}
