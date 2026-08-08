# not a stable interface, do not reference outside the codex package but make a copy if you need
{
  lib,
  stdenv,
  fetchurl,
}:

let
  # codex enables the v8 crate's `v8_enable_sandbox` feature, which implies
  # pointer compression. denoland/rusty_v8 publishes no prebuilt for that
  # feature combination, so both the static archive and the matching bindgen
  # output come from openai/codex's own rusty_v8 release. The profile string
  # must match the enabled crate features, or the v8 build script derives a
  # src binding path that does not exist and the build fails while compiling
  # `v8`. This mirrors codex's .github/actions/setup-rusty-v8.
  profile = "ptrcomp_sandbox_release";
in
{
  fetchLibrustyV8 =
    args:
    let
      target = stdenv.hostPlatform.rust.rustcTarget;
      baseUrl = "https://github.com/openai/codex/releases/download/rusty-v8-v${args.version}";
    in
    fetchurl {
      name = "librusty_v8-${args.version}";
      url = "${baseUrl}/librusty_v8_${profile}_${target}.a.gz";
      sha256 = args.shas.${stdenv.hostPlatform.system};
      passthru.srcBinding = fetchurl {
        name = "rusty_v8-src-binding-${args.version}.rs";
        url = "${baseUrl}/src_binding_${profile}_${target}.rs";
        sha256 = args.bindingShas.${stdenv.hostPlatform.system};
      };
      meta = {
        inherit (args) version;
        sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
      };
    };
}
