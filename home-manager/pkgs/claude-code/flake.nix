{
  description = "Latest Claude Code binary packaged with Nix flake";

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
        claude-code = final.callPackage ./package.nix { };
      };
      mkPkgs =
        system:
        import nixpkgs {
          inherit system;
          config.allowUnfree = true;
          overlays = [ overlay ];
        };
    in
    {
      overlays.default = overlay;
      overlays.claude-code = overlay;

      packages = forAllSystems (
        system:
        let
          pkgs = mkPkgs system;
          package = pkgs.claude-code;
        in
        {
          default = package;
          claude-code = package;
        }
      );

      apps = forAllSystems (
        system:
        let
          pkgs = mkPkgs system;
          package = pkgs.claude-code;
        in
        {
          default = {
            type = "app";
            program = "${package}/bin/claude";
          };
          claude-code = {
            type = "app";
            program = "${package}/bin/claude";
          };
        }
      );
    };
}
