# ~/nix-config/flake.nix

# init with nix run home-manager -- switch --flake .#macbook
# update with home-manager switch --flake .#macbook

{
  description = "My cross-platform home environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
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
        # bun 1.4.4 filters optional deps by host libc, so the node_modules FOD
        # differs per platform while nixpkgs still carries the bun 1.4.2 hash
        # (NixOS/nixpkgs#582673). Drop once #582675 or a follow-up lands.
        (final: prev: {
          opencode = prev.opencode.overrideAttrs (old: {
            node_modules = old.node_modules.overrideAttrs (_: {
              outputHash =
                if prev.stdenv.hostPlatform.isDarwin
                then "sha256-dIveiaiPFGSItwLyeMuPDxTE9gpvvnlTCB/+nG24qCc="
                else "sha256-prx9dX7kUvs/E3zopkaPk5LXh3xJAy5sZeum/W8L7cA=";
            });
          });
        })
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
          # aiToolsPkgs = aiToolsPkgsFor system;
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
        };
        modules = [ ./home.nix ./macos.nix ];
      }
    );
  };
}
