{
  description = "Latest OpenAI Codex CLI packaged with Nix flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs =
    { nixpkgs, ... }:
    let
      lib = nixpkgs.lib;
      systems = [
        "aarch64-darwin"
        "x86_64-darwin"
        "aarch64-linux"
        "x86_64-linux"
      ];
      forAllSystems = lib.genAttrs systems;
      overlay = final: _prev: {
        codex = final.callPackage ./package.nix { };
      };
      mkPkgs =
        system:
        import nixpkgs {
          inherit system;
          overlays = [ overlay ];
        };
    in
    {
      overlays.default = overlay;
      overlays.codex = overlay;

      packages = forAllSystems (
        system:
        let
          pkgs = mkPkgs system;
          package = pkgs.codex;
        in
        {
          default = package;
          codex = package;
        }
      );

      apps = forAllSystems (
        system:
        let
          pkgs = mkPkgs system;
          package = pkgs.codex;
        in
        {
          default = {
            type = "app";
            program = "${package}/bin/codex";
          };
          codex = {
            type = "app";
            program = "${package}/bin/codex";
          };
        }
      );
    };
}
