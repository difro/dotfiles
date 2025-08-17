# ~/nix-config/flake.nix
{
  description = "My cross-platform home environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-master.url = "github:NixOS/nixpkgs/master";
    nix-ai-tools.url = "github:numtide/nix-ai-tools";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs"; # Ensures home-manager uses the same nixpkgs
    };
  };

  outputs = { self, nixpkgs, nixpkgs-master, nix-ai-tools, home-manager }:
  let
    masterPkgsFor = system: import nixpkgs-master { inherit system; };
    aiToolsPkgsFor = system: import nix-ai-tools { inherit system; };
  in
  {
    # Configuration for your Linux machine
    homeConfigurations."linux" = home-manager.lib.homeManagerConfiguration {
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
      extraSpecialArgs = { masterPkgs = masterPkgsFor "x86_64-linux"; aiToolsPkgs = aiToolsPkgsFor "x86_64-linux"; };
      modules = [ ./home.nix ./linux.nix ];
    };

    # Configuration for your macOS machine
    homeConfigurations."macbook" = home-manager.lib.homeManagerConfiguration {
      pkgs = nixpkgs.legacyPackages.aarch64-darwin; # Or x86_64-darwin
      extraSpecialArgs = { 
       masterPkgs = masterPkgsFor "aarch64-darwin";
       inherit nix-ai-tools;
      };
      modules = [ ./home.nix ./macos.nix ];
    };
  };
}
