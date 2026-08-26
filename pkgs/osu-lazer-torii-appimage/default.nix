{
  lib,
  fetchurl,
  appimageTools,
  makeWrapper,
  imagemagick,
  runCommand,
  nix-update-script,
}:

let
  pname = "osu-lazer-torii-appimage";
  version = "2026.825.5-torii";

  src = fetchurl {
    url = "https://github.com/ShikkesoraSIM/torii-osu/releases/download/v${version}/torii-linux-x64.AppImage";
    hash = "sha256-EUQsYNnycrhy5cqaviWFQ8KEMLXHa7XT9kwYxqSJAMk=";
  };

  icon =
    let
      extracted = appimageTools.extract { inherit pname version src; };
    in
    runCommand "torii-icon"
      {
        nativeBuildInputs = [ imagemagick ];
      }
      ''
        mkdir -p $out
        magick "ICO:${extracted}/.DirIcon[6]" -resize 256x256 png:$out/torii.png
      '';

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
      install -D ${icon}/torii.png $out/share/icons/hicolor/''${i}x$i/apps/torii.png
    done
  '';

  passthru.updateScript = nix-update-script { };
})
