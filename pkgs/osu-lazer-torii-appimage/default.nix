{
  lib,
  fetchurl,
  appimageTools,
  makeWrapper,
  nix-update-script,
}:

let
  pname = "osu-lazer-torii-appimage";
  version = "2026.813.1-nova";

  src = fetchurl {
    url = "https://github.com/ShikkesoraSIM/torii-osu/releases/download/v${version}/torii-linux-x64.AppImage";
    hash = "sha256-n0S/QNKeli8B6fvWJpSmw/rFs56yaF7Nojmjd7VIRJ8=";
  };

  icon = fetchurl {
    url = "https://raw.githubusercontent.com/ShikkesoraSIM/torii-osu/master/assets/lazer.png";
    hash = "sha256-MM9N8/12AGsIoLy2oyX7L9z2pDcfdwAdo8OMvOhxvVE=";
  };

  meta = {
    description = "Torii osu! client (osu!lazer fork)";
    homepage = "https://github.com/ShikkesoraSIM/torii-osu";
    license = lib.licenses.mit;
    platforms = [ "x86_64-linux" ];
    mainProgram = "torii";
  };
in
appimageTools.wrapType2 (finalAttrs: {
  inherit
    pname
    version
    src
    meta
    ;

  extraPkgs = pkgs: with pkgs; [ icu ];

  extraInstallCommands = ''
    . ${makeWrapper}/nix-support/setup-hook
    mv -v $out/bin/${pname} $out/bin/torii
    wrapProgram $out/bin/torii --set OSU_EXTERNAL_UPDATE_PROVIDER 1
    install -m 444 -D ${finalAttrs.contents}/*.desktop -t $out/share/applications
    for i in 16 32 48 64 96 128 256 512 1024; do
      install -D ${icon} $out/share/icons/hicolor/''${i}x$i/apps/osu-torii.png
    done
  '';

  passthru.updateScript = nix-update-script { };
})
