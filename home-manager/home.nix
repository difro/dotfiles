# ~/nix-config/home.nix
# { pkgs, masterPkgs, aiToolsPkgs, ... }:
{
  pkgs,
  # aiToolsPkgs,
  pkgsStable,
  ...
}:

let
  # On Linux, repoint the Bun-compiled opencode binary to an older glibc's
  # dynamic linker. glibc 2.42's rtld_setup_main_map rejects Bun's non-spec
  # PT_LOAD ordering with an `_dl_rtld_map.l_libname` assertion; glibc 2.40
  # (from nixpkgs-stable) still accepts it.
  #
  # Upstream's build.ts runs `opencode --version` as a smoke test on the
  # host platform before installPhase, and nixpkgs' postInstall runs
  # `opencode completion` for shell completions — both need the patched
  # interpreter, so disable the smoke test and patchelf before postInstall.
  opencode = if pkgs.stdenv.hostPlatform.isLinux then
    pkgs.opencode.overrideAttrs (old: {
      preBuild = (old.preBuild or "") + ''
        substituteInPlace packages/opencode/script/build.ts \
          --replace-fail \
            'if (item.os === process.platform && item.arch === process.arch && !item.abi) {' \
            'if (false) {'
      '';
      postInstall = ''
        ${pkgs.patchelf}/bin/patchelf \
          --set-interpreter ${pkgsStable.glibc}/lib/ld-linux-x86-64.so.2 \
          $out/bin/.opencode-wrapped
      '' + (old.postInstall or "");
    })
  else
    pkgs.opencode;
in
{

  # This is a mandatory setting.
  home.stateVersion = "24.05";

  # Let Home Manager install and manager itself.
  programs.home-manager.enable = true;

  # Packages intentionally kept in Nix on all systems
  home.packages = [
    pkgs.claude-code-bin
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
