# ~/nix-config/flake.nix

# init with nix run home-manager -- switch --flake .#macbook
# update with home-manager switch --flake .#macbook

{
  description = "My cross-platform home environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-ai-tools.url = "github:numtide/nix-ai-tools";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs"; # Ensures home-manager uses the same nixpkgs
    };
  };

  outputs = { self, nixpkgs, nix-ai-tools, home-manager }:
  let
    aiToolsPkgsFor = system: nix-ai-tools.packages.${system};
  in
  {
    # Configuration for your cnd901 machine
    homeConfigurations."office" = home-manager.lib.homeManagerConfiguration (
      let
        system = "x86_64-linux"; 
      in 
      {
        pkgs = nixpkgs.legacyPackages.${system};
        extraSpecialArgs = { 
         aiToolsPkgs = aiToolsPkgsFor system;
        };
        modules = [ ./home.nix ./office.nix ];
      }
    );

    # Configuration for your macOS machine
    homeConfigurations."macos" = home-manager.lib.homeManagerConfiguration (
      let
        system = "aarch64-darwin";
      in 
      {
        pkgs = nixpkgs.legacyPackages.${system};
        extraSpecialArgs = { 
         aiToolsPkgs = aiToolsPkgsFor system;
        };
        modules = [ ./home.nix ./macos.nix ];
      }
    );
  };
}
