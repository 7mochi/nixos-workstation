{
  lib,
  stdenv,
  fetchzip,
  patchelf,
  writers,
  makeDesktopItem,
  symlinkJoin,
  mesa,
  libGL,
  wayland,
  libxkbcommon,
  icu,
  libX11,
  libxcb,
  libXext,
  libXrandr,
  libXcursor,
  libXi,
  libXfixes,
  vulkan-loader,
  alsa-lib,
  pipewire,
  openssl,
  libudev-zero,
  libgdiplus,
}:

let
  pname = "retrogecko";
  version = "b1135";

  src = fetchzip {
    inherit version;
    pname = "retrogecko-src";
    url = "https://jvyden.xyz/gex/retro/retrogecko-${version}-linux-x64.zip";
    hash = "sha256-YMa3JxkqmAlMAPckQT3YuPx+tiqOXlWl2YISMiefvso=";
    stripRoot = false;
  };

  runtimeLibs = lib.makeLibraryPath [
    stdenv.cc.cc.lib
    mesa
    libGL
    wayland
    libxkbcommon
    icu
    libX11
    libxcb
    libXext
    libXrandr
    libXcursor
    libXi
    libXfixes
    vulkan-loader
    alsa-lib
    pipewire
    openssl
    libudev-zero
    libgdiplus
  ];

  rpath = "${stdenv.cc.cc.lib}/lib:\$ORIGIN";

  desktopItem = makeDesktopItem {
    name = "retrogecko";
    exec = "retrogecko";
    icon = "retrogecko";
    desktopName = "RetroGecko";
    comment = "osu! client for titanic.sh";
    categories = [ "Game" ];
  };

  launcher = writers.writeBashBin pname ''
    APP_DIR="''${XDG_DATA_HOME:-$HOME/.local/share}/retrogecko"
    VERSION_MARKER="$APP_DIR/.retrogecko-version"
    if [ ! -f "$VERSION_MARKER" ] || [ "$(cat "$VERSION_MARKER")" != "${version}" ]; then
      mkdir -p "$APP_DIR"
      cp -r ${drv}/lib/retrogecko/. "$APP_DIR/"
      chmod -R u+w "$APP_DIR"
      echo "${version}" > "$VERSION_MARKER"
    fi
    export LD_LIBRARY_PATH="$APP_DIR:${runtimeLibs}''${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
    exec "$APP_DIR/osu!" "$@"
  '';

  drv = stdenv.mkDerivation {
    inherit pname version src;

    nativeBuildInputs = [ patchelf ];

    dontStrip = true;

    buildPhase = ''
      runHook preBuild
      for f in osu! createdump; do
        patchelf --set-interpreter ${stdenv.cc.bintools.dynamicLinker} --set-rpath ${rpath} "$f"
      done
      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall
      mkdir -p $out/lib/retrogecko
      cp -r * $out/lib/retrogecko/
      for f in $out/lib/retrogecko/*.so; do
        patchelf --set-rpath ${rpath} "$f"
      done
      install -Dm644 osu!.png $out/share/icons/hicolor/256x256/apps/retrogecko.png
      runHook postInstall
    '';

    meta = {
      description = "RetroGecko osu! client (titanic.sh)";
      homepage = "https://osu.titanic.sh/forum/23/t/1290/";
      license = lib.licenses.unfree;
      platforms = [ "x86_64-linux" ];
      mainProgram = "retrogecko";
    };

    passthru.updateScript = ./update.sh;
  };
in
symlinkJoin {
  name = "${pname}-${version}";
  paths = [
    drv
    launcher
    desktopItem
  ];
}
