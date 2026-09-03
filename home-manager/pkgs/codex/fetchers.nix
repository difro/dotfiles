# not a stable interface, do not reference outside the codex package but make a copy if you need
{
  lib,
  stdenv,
  fetchurl,
}:

let
  # codex's code-mode-runtime enables the v8 crate's `v8_enable_sandbox`
  # feature, and denoland/rusty_v8 publishes no prebuilt for that profile.
  # Both the archive and its bindgen output therefore come from openai/codex's
  # own rusty-v8 release, as codex's setup-rusty-v8 action does. The profile
  # must match the enabled crate features. Keep it in sync with update-librusty.sh.
  profile = "ptrcomp_sandbox_release";
  baseUrl = version: "https://github.com/openai/codex/releases/download/rusty-v8-v${version}";
in
{
  fetchLibrustyV8 =
    args:
    fetchurl {
      name = "librusty_v8-${args.version}";
      url = "${baseUrl args.version}/librusty_v8_${profile}_${stdenv.hostPlatform.rust.rustcTarget}.a.gz";
      sha256 = args.shas.${stdenv.hostPlatform.system};
      meta = {
        inherit (args) version;
        sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
      };
    };

  fetchLibrustyV8SrcBinding =
    args:
    fetchurl {
      name = "src_binding-${args.version}";
      url = "${baseUrl args.version}/src_binding_${profile}_${stdenv.hostPlatform.rust.rustcTarget}.rs";
      sha256 = args.shas.${stdenv.hostPlatform.system};
      meta = {
        inherit (args) version;
        sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
      };
    };
}
