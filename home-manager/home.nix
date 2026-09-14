# ~/nix-config/home.nix
# { pkgs, masterPkgs, aiToolsPkgs, ... }:
{
  pkgs,
  # aiToolsPkgs,
  pkgsStable,
  pkgsBun,
  ...
}:

let
  # opencode 1.18.30 has a latent circular import (opencode#48819). Bun 1.4's
  # bundler evaluates those modules in an order that leaves a layer dependency
  # undefined, so every prompt dies in SystemPrompt.environment with
  # `TypeError: undefined is not an object (evaluating 'a.name')`. Bun 1.3.13
  # produces a working bundle; drop this once opencode ships the fix.
  opencodeBase = pkgs.opencode.override { bun = pkgsBun.bun; };

  # On Linux, repoint the Bun-compiled opencode binary to an older glibc's
  # dynamic linker. glibc 2.42's rtld_setup_main_map rejects Bun's non-spec
  # PT_LOAD ordering with an `_dl_rtld_map.l_libname` assertion; glibc 2.40
  # (from nixpkgs-stable) still accepts it.
  #
  # nixpkgs' postInstall runs `opencode completion` for shell completions, so
  # patchelf has to run before it.
  opencode = if pkgs.stdenv.hostPlatform.isLinux then
    opencodeBase.overrideAttrs (old: {
      postInstall = ''
        ${pkgs.patchelf}/bin/patchelf \
          --set-interpreter ${pkgsStable.glibc}/lib/ld-linux-x86-64.so.2 \
          $out/bin/.opencode-wrapped
      '' + (old.postInstall or "");
    })
  else
    opencodeBase;
in
{

  # This is a mandatory setting.
  home.stateVersion = "24.05";

  # Let Home Manager install and manager itself.
  programs.home-manager.enable = true;

  # Packages intentionally kept in Nix on all systems
  home.packages = [
    pkgs.gh-dash
    pkgs.man-pages
    opencode
  ];

  nixpkgs.config.allowUnfree = true; # Allow unfree packages
  nixpkgs.config.allowUnsupportedSystem = true; # Allow unsupported systems


  # Example: Manage a dotfile declaratively
  # home.file.".gitconfig".text = ''
  #   [user]
  #     name = Your Name
  #     email = your.email@example.com
  # '';
  #
  # # Configure your shell
  # programs.zsh = {
  #   enable = true;
  #   oh-my-zsh.enable = true;
  # };
}
