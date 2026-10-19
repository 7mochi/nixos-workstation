{
  lib,
  stdenv,
  fetchurl,
  appimageTools,
  cacert,
  writers,
  makeDesktopItem,
  nix-update-script,
}:

let
  pname = "ctr-nitro-fueled-appimage";
  version = "0.5.2";

  src = fetchurl {
    url = "https://github.com/Ryu7w7/OCTR-NitroFueled-PC/releases/download/v${version}/SacredFire-v${version}-x86_64.AppImage";
    hash = "sha256-1MmW848JRLGOm/QUuoPnm6lpfy2CNctgdPCPAVP7JjM=";
  };

  iconName = "io.github.sacredfire.Launcher";

  contents = appimageTools.extract { inherit pname version src; };

  launcher = writers.writeBashBin "sacredfire" ''
    runtime_dir="''${XDG_CACHE_HOME:-$HOME/.cache}/sacredfire/appdir"
    rm -rf "$runtime_dir"
    mkdir -p "$runtime_dir/mountroot"
    cp -P ${contents}/AppRun "$runtime_dir/AppRun"
    chmod u+x "$runtime_dir/AppRun"
    ln -s ${contents}/nix "$runtime_dir/nix"
    cp -P ${contents}/entrypoint "$runtime_dir/entrypoint"
    install -m444 ${cacert}/etc/ssl/certs/ca-bundle.crt "$runtime_dir/ca-bundle.crt"
    export SSL_CERT_FILE="$runtime_dir/ca-bundle.crt"
    export NIX_SSL_CERT_FILE="$runtime_dir/ca-bundle.crt"
    exec "$runtime_dir/AppRun" "$@"
  '';

  desktopItem = makeDesktopItem {
    name = "sacredfire";
    exec = "sacredfire";
    icon = iconName;
    desktopName = "SacredFire";
    categories = [ "Game" ];
  };
in
stdenv.mkDerivation {
  inherit
    pname
    version
    src
    ;

  dontUnpack = true;

  installPhase = ''
    runHook preInstall

    install -Dm755 ${launcher}/bin/sacredfire $out/bin/sacredfire
    install -Dm444 ${desktopItem}/share/applications/sacredfire.desktop \
      $out/share/applications/sacredfire.desktop

    for i in 16 32 48 64 96 128 256 512 1024; do
      install -Dm444 ${contents}/usr/share/icons/hicolor/256x256/apps/${iconName}.png \
        $out/share/icons/hicolor/''${i}x$i/apps/${iconName}.png
    done

    runHook postInstall
  '';

  meta = {
    description = "SacredFire launcher for your own copy of Crash Team Racing: Nitro-Fueled (Online CTR)";
    homepage = "https://github.com/Ryu7w7/OCTR-NitroFueled-PC";
    license = lib.licenses.gpl2Only;
    platforms = [ "x86_64-linux" ];
    mainProgram = "sacredfire";
  };

  passthru.updateScript = nix-update-script { };
}
