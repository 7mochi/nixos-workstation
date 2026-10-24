{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  makeDesktopItem,
  writers,
  symlinkJoin,
  libGL,
  libX11,
  libxcb,
  zlib,
  gmp,
  libgpg-error,
  e2fsprogs,
  writeShellApplication,
  curl,
  git,
  jq,
  nix,
  gnused,
  coreutils,
  gnugrep,
  gawk,
}:

let
  pname = "power-bomberman";
  version = "0.7.8c";

  meta = {
    description = "Power Bomberman ${version}";
    homepage = "https://www.bombermanboard.com/viewtopic.php?t=1925";
    license = lib.licenses.unfree;
    platforms = [ "x86_64-linux" ];
    mainProgram = pname;
  };

  updateScriptBin = writeShellApplication {
    name = "update-power-bomberman";
    runtimeInputs = [
      coreutils
      curl
      gawk
      git
      gnugrep
      gnused
      jq
      nix
    ];
    text = ''
      cd "$(git rev-parse --show-toplevel)"
      FILE="pkgs/power-bomberman/package.nix"
      PAGE="$(curl -fsSL "https://www.bombermanboard.com/viewtopic.php?t=1925")"

      version="$(printf '%s\n' "$PAGE" | grep -oE 'FULL GAME \([^)]+\)' | head -1 | sed -E 's/.*\((.*)\)/\1/')"
      drive_id="$(printf '%s\n' "$PAGE" | grep -oE 'https://drive\.google\.com/file/d/[A-Za-z0-9_-]+' | awk '!seen[$0]++' | sed -n '3p' | sed 's|.*/d/||')"
      src_url="https://drive.usercontent.google.com/download?id=$drive_id&export=download&confirm=t"
      hash="$(nix store prefetch-file --json --hash-type sha256 "$src_url" | jq -r .hash)"

      sed -i -E "s|version = \"[^\"]+\"|version = \"$version\"|" "$FILE"
      sed -i -E "s|id=[A-Za-z0-9_-]+|id=$drive_id|" "$FILE"
      sed -i -E "s|hash = \"[^\"]+\"|hash = \"$hash\"|" "$FILE"
    '';
  };

  updateScript = [ "${updateScriptBin}/bin/update-power-bomberman" ];

  # https://www.bombermanboard.com/viewtopic.php?t=1925
  src = fetchurl {
    url = "https://drive.usercontent.google.com/download?id=17OP_OZgxsUdu_np7Pcq5muuQUC0tvAG4&export=download&confirm=t";
    hash = "sha256-6G9Ac9Dl6kiFxQFrVRXD9NweEZNZ8kROVxH4/TxYqL4=";
  };

  desktopItem = makeDesktopItem {
    name = pname;
    exec = pname;
    icon = "power-bomberman";
    desktopName = "Power Bomberman";
    comment = "Power Bomberman ${version}";
    categories = [ "Game" ];
  };

  launcher = writers.writeBashBin pname ''
    APP_DIR="''${XDG_DATA_HOME:-$HOME/.local/share}/power-bomberman"
    VERSION_MARKER="$APP_DIR/.power-bomberman-version"
    if [ ! -f "$VERSION_MARKER" ] || [ "$(cat "$VERSION_MARKER")" != "${version}" ]; then
      mkdir -p "$APP_DIR"
      cp -r ${drv}/. "$APP_DIR/"
      chmod -R u+w "$APP_DIR"
      echo "${version}" > "$VERSION_MARKER"
    fi
    cd "$APP_DIR"
    exec ./pb "$@"
  '';

  drv = stdenv.mkDerivation {
    inherit
      pname
      version
      src
      meta
      ;

    nativeBuildInputs = [ autoPatchelfHook ];

    buildInputs = [
      libGL
      libX11
      libxcb
      zlib
      gmp
      libgpg-error
      e2fsprogs
    ];

    runtimeDependencies = [
      e2fsprogs
    ];

    dontStrip = true;
    dontUnpack = true;

    buildPhase = ''
      runHook preBuild
      tar -xzf $src
      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall
      mkdir -p $out
      cp -r pb assets lib $out/
      install -Dm644 assets/icon.png $out/share/icons/hicolor/256x256/apps/power-bomberman.png
      runHook postInstall
    '';
  };
in
(symlinkJoin {
  name = "${pname}-${version}";
  paths = [
    drv
    launcher
    desktopItem
  ];
})
// {
  inherit
    version
    src
    updateScript
    meta
    ;
  passthru.updateScript = updateScript;
}
