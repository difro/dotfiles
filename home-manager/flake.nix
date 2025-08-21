# ~/nix-config/flake.nix

# init with nix run home-manager -- switch --flake .#macbook
# update with home-manager switch --flake .#macbook

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
    aiToolsPkgsFor = system: nix-ai-tools.packages.${system};
  in
  {
    # Configuration for your Linux machine
    homeConfigurations."linux" = home-manager.lib.homeManagerConfiguration (
      let
        system = "x86_64-linux"; 
      in 
      {
        pkgs = nixpkgs.legacyPackages.${system};
        extraSpecialArgs = { 
         masterPkgs = masterPkgsFor system;
         aiToolsPkgs = aiToolsPkgsFor system;
        };
        modules = [ ./home.nix ./linux.nix ];
      }
    );

    # Configuration for your cnd901 machine
    homeConfigurations."office" = home-manager.lib.homeManagerConfiguration (
      let
        system = "x86_64-linux"; 
      in 
      {
        pkgs = nixpkgs.legacyPackages.${system};
        extraSpecialArgs = { 
         masterPkgs = masterPkgsFor system;
         aiToolsPkgs = aiToolsPkgsFor system;
        };
        modules = [ ./home.nix ./office.nix ];
      }
    );

    # Configuration for your macOS machine
    homeConfigurations."macbook" = home-manager.lib.homeManagerConfiguration (
      let
        system = "aarch64-darwin";
      in 
      {
        pkgs = nixpkgs.legacyPackages.${system};
        extraSpecialArgs = { 
         masterPkgs = masterPkgsFor system;
         aiToolsPkgs = aiToolsPkgsFor system;
        };
        modules = [ ./home.nix ./macos.nix ];
      }
    );
  };
}
