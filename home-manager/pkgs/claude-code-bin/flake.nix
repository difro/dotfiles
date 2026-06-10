{
  description = "Latest Claude Code binary packaged with Nix flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
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
        claude-code-bin = final.callPackage ./package.nix { };
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
      overlays.claude-code-bin = overlay;

      packages = forAllSystems (
        system:
        let
          pkgs = mkPkgs system;
          package = pkgs.claude-code-bin;
        in
        {
          default = package;
          claude-code-bin = package;
        }
      );

      apps = forAllSystems (
        system:
        let
          pkgs = mkPkgs system;
          package = pkgs.claude-code-bin;
        in
        {
          default = {
            type = "app";
            program = "${package}/bin/claude";
          };
          claude-code-bin = {
            type = "app";
            program = "${package}/bin/claude";
          };
        }
      );
    };
}
