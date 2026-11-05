{
  lib,
  stdenv,
  fetchzip,
  nix-update-script,
}:

let
  pname = "rehlds";
  version = "3.15.0.896";

  meta = {
    description = "Reverse-engineered and bugfixed HLDS engine replacement";
    homepage = "https://github.com/rehlds/ReHLDS";
    license = lib.licenses.mit;
    platforms = [ "x86_64-linux" ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };

  updateScript = nix-update-script { extraArgs = [ "--flake" ]; };

  src = fetchzip {
    url = "https://github.com/rehlds/ReHLDS/releases/download/${version}/rehlds-bin-${version}.zip";
    hash = "sha256-y4tiwwEl4Fbr7DOAhBGnAlN8WmJQTcjh+FzDdkarTb4=";
    stripRoot = false;
  };
in
stdenv.mkDerivation {
  inherit
    pname
    version
    src
    meta
    ;

  dontBuild = true;
  dontStrip = true;

  installPhase = ''
    runHook preInstall
    install -Dm755 $src/bin/linux32/engine_i486.so $out/lib/engine_i486.so
    runHook postInstall
  '';

  passthru.updateScript = updateScript;
}
