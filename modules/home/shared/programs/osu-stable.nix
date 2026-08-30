_:

{
  flake.modules.homeManager.shared =
    { inputs, lib, ... }:
    {
      imports = [ inputs.nix-osu-stable.homeModules.osu-stable ];

      programs.osu-stable = {
        enable = true;
        arrpc = true;

        settings = {
          VolumeUniversal = 5;
          VolumeEffect = 50;
          VolumeMusic = 60;
          Offset = -35;
          FrameSync = "Unlimited";
          CustomFrameLimit = 240;
          HighResolution = 0;
          Fullscreen = 0;
          WidthFullscreen = 1920;
          HeightFullscreen = 1080;
          RefreshRate = 60;
          ScaleMode = "WidescreenConservative";
          ConfineMouse = "Fullscreen";
          RawInput = 0;
          MouseSpeed = 1;
          MouseDisableButtons = 1;
          AutomaticCursorSizing = 0;
          CursorSize = 1.04;
          DimLevel = 100;
          IHateHavingFun = 1;
          DiscordRichPresence = 1;
          KeyOverlay = 1;
          ShowStoryboard = 0;
          Video = 0;
          Shaders = 0;
          Skin = "Default";
          SkinSamples = 1;
          UseSkinCursor = 0;
          IgnoreBeatmapSkins = 1;
          IgnoreBeatmapSamples = 1;
          ManiaSpeed = 20;
          UsePerBeatmapManiaSpeed = 0;
          PopupDuringGameplay = 0;
          ScoreMeter = "Error";
          ProgressBarType = "Pie";
          RankType = "Local";
          MenuTriangles = 1;
          SongSelectThumbnails = 1;
          ShowSpectators = 1;
          MinimiseOnAltTabFullscreen = 1;

          keyOsuLeft = "C";
          keyOsuRight = "Z";
          keyOsuSmoke = "H";
          keyFruitsDash = "S";
          keyFruitsLeft = "H";
          keyFruitsRight = "K";
          keyTaikoInnerLeft = "X";
          keyTaikoInnerRight = "C";
          keyTaikoOuterLeft = "Z";
          keyTaikoOuterRight = "V";
          keyPause = "Escape";
          keySkip = "Space";
          keyToggleScoreboard = "Tab";
          keyToggleChat = "F8";
          keyToggleExtendedChat = "F9";
          keyScreenshot = "F12";
          keyIncreaseAudioOffset = "OemPlus";
          keyDecreaseAudioOffset = "OemMinus";
          keyQuickRetry = "OemTilde";
          keyIncreaseSpeed = "F4";
          keyDecreaseSpeed = "F3";
          keyToggleFrameLimiter = "F7";
          keyVolumeIncrease = "Up";
          keyVolumeDecrease = "Down";
          keyDisableMouseButtons = "F10";
          keyBossKey = "Insert";
          keyEasy = "Q";
          keyNoFail = "W";
          keyHalfTime = "E";
          keyHardRock = "A";
          keySuddenDeath = "S";
          keyDoubleTime = "D";
          keyHidden = "F";
          keyFlashlight = "G";
          keyRelax = "Z";
          keyAutopilot = "X";
          keySpunOut = "C";
          keyAuto = "V";
          keyScoreV2 = "B";
        };
      };

      home.activation.osuStableLink = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        mkdir -p "$HOME/.local/share/nix-osu-stable"
        ln -sfn "/media/ssd/other_games/osu!stable/osu!" "$HOME/.local/share/nix-osu-stable/osu"
      '';
    };
}
