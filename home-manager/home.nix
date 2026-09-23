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
  # nixpkgs' postInstall runs `opencode completion` for shell completions, so
  # patchelf has to run before it.
  opencode = if pkgs.stdenv.hostPlatform.isLinux then
    pkgs.opencode.overrideAttrs (old: {
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
