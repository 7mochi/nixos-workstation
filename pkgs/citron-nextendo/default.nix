{
  lib,
  fetchurl,
  appimageTools,
  runCommand,
  dwarfs,
  binutils-unwrapped,
  makeDesktopItem,
  symlinkJoin,
}:

let
  pname = "citron-nextendo";
  version = "ddfd42a1c";

  src = fetchurl {
    url = "https://github.com/NextendoNetwork/citron-nextendo/releases/download/nightly-linux/citron_nightly-${version}-linux-x86_64_v3.AppImage";
    hash = "sha256-XvGX02D8qMGwOu14otRFZbDEyfS6QoDy8XQtpxFoZeg=";
  };

  contents =
    runCommand "${pname}-${version}-extracted"
      {
        nativeBuildInputs = [
          dwarfs
          binutils-unwrapped
        ];
      }
      ''
        mkdir -p $out
        offset=$(LC_ALL=C readelf -h ${src} | awk 'NR==13{e_shoff=$5} NR==18{e_shentsize=$5} NR==19{e_shnum=$5} END{print e_shoff+e_shentsize*e_shnum}')
        dwarfsextract -i ${src} -o $out -O $offset
        chmod -R u+w $out
      '';

  meta = {
    description = "Citron Nextendo - Nintendo Switch emulator with Nextendo Network online support (nightly)";
    homepage = "https://github.com/NextendoNetwork/citron-nextendo";
    license = lib.licenses.gpl2Plus;
    platforms = [ "x86_64-linux" ];
    mainProgram = pname;
  };

  desktopItem = makeDesktopItem {
    name = pname;
    exec = pname;
    icon = pname;
    desktopName = "Citron Nextendo";
    comment = "Nintendo Switch video game console emulator";
    categories = [
      "Game"
      "Emulator"
    ];
  };

  wrapped = appimageTools.wrapAppImage {
    inherit
      pname
      version
      contents
      meta
      ;

    extraInstallCommands = ''
      for i in 16 32 48 64 96 128 256 512 1024; do
        install -D ${contents}/org.citron_emu.citron.png \
          $out/share/icons/hicolor/''${i}x$i/apps/${pname}.png
      done
    '';
  };
in
symlinkJoin {
  name = "${pname}-${version}";
  paths = [
    wrapped
    desktopItem
  ];
}
