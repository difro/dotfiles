# ~/nix-config/flake.nix

# init with nix run home-manager -- switch --flake .#macbook
# update with home-manager switch --flake .#macbook

{
  description = "My cross-platform home environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    # Pinned older nixpkgs (glibc 2.40) used to patch opencode's interpreter:
    # nixpkgs-unstable ships glibc 2.42 whose stricter rtld_setup_main_map
    # check rejects Bun-compiled binaries (extra PT_LOAD out of vaddr order).
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-25.05";
    # Pinned nixpkgs that still has Bun 1.3.13, used to build opencode:
    # opencode 1.18.30 has a latent circular import (opencode#48819), and Bun
    # 1.4's bundler orders module evaluation so that a layer dependency ends up
    # undefined, which kills every prompt in SystemPrompt.environment.
    nixpkgs-bun.url = "github:NixOS/nixpkgs/1927682e0d808b4a695910f76562b11e2ddecab4";
    # nix-ai-tools.url = "github:numtide/nix-ai-tools";
    claude-code = {
      url = "path:./pkgs/claude-code";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    codex.url = "path:./pkgs/codex";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs"; # Ensures home-manager uses the same nixpkgs
    };
  };

  outputs = {
    self,
    nixpkgs,
    nixpkgs-stable,
    nixpkgs-bun,
    # nix-ai-tools,
    claude-code,
    codex,
    home-manager,
  }:
  let
    # aiToolsPkgsFor = system: nix-ai-tools.packages.${system};
    pkgsFor = system: import nixpkgs {
      inherit system;
      config.allowUnfree = true;
      overlays = [
        claude-code.overlays.default
        codex.overlays.default
      ];
    };
    pkgsStableFor = system: import nixpkgs-stable {
      inherit system;
      config.allowUnfree = true;
    };
    pkgsBunFor = system: import nixpkgs-bun {
      inherit system;
      config.allowUnfree = true;
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
          # aiToolsPkgs = aiToolsPkgsFor system;
          pkgsStable = pkgsStableFor system;
          pkgsBun = pkgsBunFor system;
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
          # aiToolsPkgs = aiToolsPkgsFor system;
          pkgsStable = pkgsStableFor system;
          pkgsBun = pkgsBunFor system;
        };
        modules = [ ./home.nix ./macos.nix ];
      }
    );
  };
}
