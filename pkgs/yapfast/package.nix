{
  lib,
  appimageTools,
  fetchurl,
  nix-update-script,
}:

let
  pname = "yapfast";
  version = "0.4.1";

  meta = {
    description = "Yapfast, a native Discord client";
    homepage = "https://github.com/yapfast/yapfast";
    license = lib.licenses.gpl3Only;
    platforms = [ "x86_64-linux" ];
    mainProgram = pname;
  };

  updateScript = nix-update-script { extraArgs = [ "--flake" ]; };

  src = fetchurl {
    url = "https://github.com/yapfast/yapfast/releases/download/v${version}/Yapfast-${version}-x86_64.AppImage";
    hash = "sha256-FT0loZpUtcmI5m6kn1tyZaNwezPe8cUEY3R60r5nFEw=";
  };
in
appimageTools.wrapType2 (finalAttrs: {
  inherit
    pname
    version
    src
    meta
    ;

  extraPkgs =
    pkgs: with pkgs; [
      libGL
      libgbm
      alsa-lib
      libpulseaudio
    ];

  extraInstallCommands = ''
    install -m 444 -D ${finalAttrs.contents}/usr/share/applications/io.github.yapfast.Yapfast.desktop \
      $out/share/applications/io.github.yapfast.Yapfast.desktop
    install -m 444 -D ${finalAttrs.contents}/usr/share/icons/hicolor/scalable/apps/io.github.yapfast.Yapfast.svg \
      $out/share/icons/hicolor/scalable/apps/io.github.yapfast.Yapfast.svg
  '';

  passthru.updateScript = updateScript;
})
