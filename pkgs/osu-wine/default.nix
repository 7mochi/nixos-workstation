{
  lib,
  stdenv,
  fetchurl,
  patchelf,
  writers,
  writeTextFile,
  symlinkJoin,
  curl,
  coreutils,
  gnutar,
  gnused,
  gnugrep,
  nix-update-script,
  libGL,
  mesa,
  wayland,
  libxkbcommon,
  libX11,
  libxcb,
  libXext,
  libXrandr,
  libXi,
  libXcursor,
  libXfixes,
  freetype,
  fontconfig,
  dbus,
  libudev-zero,
  alsa-lib,
  pulseaudio,
  pipewire,
  gnutls,
  libxml2,
  zlib,
  gst_all_1,
  vulkan-loader,
}:

let
  pname = "osu-wine";
  version = "11.12-2";

  wine-osu-src = fetchurl {
    url = "https://github.com/NelloKudo/WineBuilder/releases/download/wine-osu-staging-${version}/wine-osu-winello-fonts-wow64-${version}-x86_64.tar.xz";
    hash = "sha256-fk9ZCmXwEa7PpXifOJleUMPOjq9hO9rO8kqPCXYk0J8=";
  };

  wine-osu = stdenv.mkDerivation {
    pname = "wine-osu";
    inherit version;

    src = wine-osu-src;

    nativeBuildInputs = [ patchelf ];

    dontStrip = true;

    buildPhase = ''
      runHook preBuild
      for f in $(find . -type f -executable); do
        patchelf --set-interpreter ${stdenv.cc.bintools.dynamicLinker} --set-rpath '$ORIGIN' "$f" || true
      done
      for f in $(find . -type f -name '*.so'); do
        patchelf --set-rpath '$ORIGIN' "$f" || true
      done
      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall
      mkdir -p $out/lib/wine-osu
      cp -r * $out/lib/wine-osu/
      runHook postInstall
    '';
  };

  osu-prefix = fetchurl {
    url = "https://github.com/NelloKudo/osu-winello/releases/download/winello-bins/osu-winello-prefix.tar.xz";
    hash = "sha256-AJz+GMFE4WNIsap+O1YceTI1qFkfsLKv+loqzqdoJ0M=";
  };

  icon = fetchurl {
    url = "https://raw.githubusercontent.com/NelloKudo/osu-winello/main/stuff/osu-wine.png";
    hash = "sha256-kn3mKfwpeTRScvxbH7jKbo+7zGDIozFkNVW8BmbayvQ=";
  };

  runtimeLibs = lib.makeLibraryPath [
    libGL
    mesa
    wayland
    libxkbcommon
    libX11
    libxcb
    libXext
    libXrandr
    libXi
    libXcursor
    libXfixes
    freetype
    fontconfig
    dbus
    libudev-zero
    alsa-lib
    pulseaudio
    pipewire
    gnutls
    libxml2
    zlib
    gst_all_1.gstreamer
    vulkan-loader
  ];

  wineDirs = "${wine-osu}/lib/wine-osu/lib:${wine-osu}/lib/wine-osu/lib/wine/x86_64-unix";

  desktopItem = writeTextFile {
    name = "osu-wine.desktop";
    destination = "/share/applications/osu-wine.desktop";
    text = ''
      [Desktop Entry]
      Type=Application
      Name=osu!(stable)
      Comment=osu!(stable) - Rhythm is just a *click* away!
      Exec=osu-wine %U
      Icon=osu-wine
      Terminal=false
      Categories=Wine;Game
    '';
  };

  launcher = writers.writeBashBin pname ''
    export XDG_DATA_HOME="''${XDG_DATA_HOME:-$HOME/.local/share}"
    export WINEPREFIX="''${WINEPREFIX:-$XDG_DATA_HOME/wineprefixes/osu-wineprefix}"
    export WINEDLLOVERRIDES="''${WINEDLLOVERRIDES:-winemenubuilder.exe=;}" # Blocks wine from creating .desktop files
    export LD_LIBRARY_PATH="${wineDirs}:${runtimeLibs}''${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"

    [ -n "''${WAYLAND_DISPLAY:-}" ] && unset DISPLAY

    WINE=${wine-osu}/lib/wine-osu/bin/wine
    WINESERVER=${wine-osu}/lib/wine-osu/bin/wineserver
    export WINE_INSTALL_PATH=${wine-osu}/lib/wine-osu
    OSUPATH="''${OSUPATH:-$XDG_DATA_HOME/osu-wine}"

    setup_prefix() {
      if [ ! -f "$WINEPREFIX/system.reg" ]; then
        ${coreutils}/bin/mkdir -p "$XDG_DATA_HOME/wineprefixes"
        ${gnutar}/bin/tar -xf ${osu-prefix} -C "$XDG_DATA_HOME/wineprefixes"
        [ -d "$XDG_DATA_HOME/wineprefixes/osu-prefix" ] && \
          ${coreutils}/bin/mv "$XDG_DATA_HOME/wineprefixes/osu-prefix" "$WINEPREFIX"
        ${coreutils}/bin/chmod -R u+w "$WINEPREFIX"
        ${gnused}/bin/sed -i -e "s|nellokudo|''${USER}|g" \
          "$WINEPREFIX"/{userdef.reg,user.reg,system.reg}
        ${coreutils}/bin/rm -rf "$WINEPREFIX/drive_c/users/nellokudo"
        ${coreutils}/bin/rm -rf "$WINEPREFIX/dosdevices"
        ${coreutils}/bin/mkdir -p "$WINEPREFIX/dosdevices"
        ${coreutils}/bin/ln -s "$WINEPREFIX/drive_c/" "$WINEPREFIX/dosdevices/c:"
        ${coreutils}/bin/ln -s / "$WINEPREFIX/dosdevices/z:"
        ${coreutils}/bin/ln -s "$OSUPATH" "$WINEPREFIX/dosdevices/d:"
        "$WINESERVER" -w
        "$WINE" wineboot -u
      fi
    }

    # Allow using bundled gstreamer
    if [ -f "$WINE_INSTALL_PATH/lib/wine/x86_64-unix/libgstfaad.so" ]; then
      export GST_PLUGIN_SYSTEM_PATH_1_0="$WINE_INSTALL_PATH/lib/wine/x86_64-unix"
      export WINE_GST_REGISTRY_DIR="$WINEPREFIX/gstreamer-1.0"
      ${coreutils}/bin/mkdir -p "$WINE_GST_REGISTRY_DIR"
    fi

    detect_abs_tablet_hack() {
      [ -n "''${WINE_ENABLE_ABS_TABLET_HACK+x}" ] && return 1
      if [ "''${XDG_SESSION_TYPE:-}" != "wayland" ] && [ -z "''${WAYLAND_DISPLAY:-}" ]; then
        return 1
      fi
      [ -r /proc/bus/input/devices ] || return 1
      ${gnugrep}/bin/grep -q 'Name="OpenTabletDriver Virtual Tablet"' /proc/bus/input/devices || return 1
      local settings_json
      for settings_json in \
        "$HOME/.config/OpenTabletDriver/settings.json" \
        "$HOME/.var/app/net.opentabletdriver.OpenTabletDriver/config/OpenTabletDriver/settings.json"; do
        [ -r "$settings_json" ] || continue
        ${gnugrep}/bin/grep -Eq '"Enable"[[:space:]]*:[[:space:]]*true' "$settings_json" &&
          ${gnugrep}/bin/grep -Eq '"Path"[[:space:]]*:[[:space:]]*".*\.AbsoluteMode"' "$settings_json" &&
          return 0
      done
      return 1
    }

    setup_prefix
    if detect_abs_tablet_hack; then
      export WINE_ENABLE_ABS_TABLET_HACK=2
    fi

    if [ "$1" = "--wine" ]; then
      shift
      exec "$WINE" "$@"
    fi

    if [ ! -f "$OSUPATH/osu!.exe" ] && [ -f "$OSUPATH/osu!/osu!.exe" ]; then
      OSUPATH="$OSUPATH/osu!"
    fi
    if [ ! -f "$OSUPATH/osu!.exe" ]; then
      echo "osu! not found in $OSUPATH, downloading osu!.exe..."
      ${coreutils}/bin/mkdir -p "$OSUPATH"
      ${curl}/bin/curl -fL -o "$OSUPATH/osu!.exe" "https://m1.ppy.sh/r/osu!install.exe"
    fi

    cd "$OSUPATH" || { echo "osu! path '$OSUPATH' not found (set OSUPATH)."; exit 1; }
    exec "$WINE" osu!.exe "$@"
  '';
in
symlinkJoin {
  name = "${pname}-${version}";
  paths = [
    launcher
    desktopItem
  ];

  passthru = {
    inherit
      pname
      version
      ;
    src = wine-osu-src;
    updateScript = nix-update-script {
      extraArgs = [ "--version-regex=^wine-osu-staging-(.+)$" ];
    };
  };

  postBuild = ''
    mkdir -p $out/share/icons/hicolor/256x256/apps
    ln -s ${icon} $out/share/icons/hicolor/256x256/apps/osu-wine.png
  '';

  meta = {
    description = "Stable osu! client running under wine-osu";
    homepage = "https://github.com/NelloKudo/osu-winello";
    license = [
      lib.licenses.lgpl21Plus
      lib.licenses.gpl3Plus
    ];
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "osu-wine";
  };
}
