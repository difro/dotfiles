# ~/nix-config/flake.nix

# init with nix run home-manager -- switch --flake .#macbook
# update with home-manager switch --flake .#macbook

{
  description = "My cross-platform home environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-ai-tools.url = "github:numtide/nix-ai-tools";
    claude-code-bin.url = "path:./pkgs/claude-code-bin";
    codex.url = "path:./pkgs/codex";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs"; # Ensures home-manager uses the same nixpkgs
    };
  };

  outputs = { self, nixpkgs, nix-ai-tools, claude-code-bin, codex, home-manager }:
  let
    aiToolsPkgsFor = system: nix-ai-tools.packages.${system};
    pkgsFor = system: import nixpkgs {
      inherit system;
      config.allowUnfree = true;
      overlays = [
        claude-code-bin.overlays.default
        codex.overlays.default
      ];
    };
  in
  {
    # Configuration for your cnd901 machine
    homeConfigurations."office" = home-manager.lib.homeManagerConfiguration (
      let
        system = "x86_64-linux"; 
      in 
      {
        pkgs = pkgsFor system;
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
        pkgs = pkgsFor system;
        extraSpecialArgs = {
          aiToolsPkgs = aiToolsPkgsFor system;
        };
        modules = [ ./home.nix ./macos.nix ];
      }
    );
  };
}
