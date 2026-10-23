_:

{
  flake.modules.homeManager.equibop =
    { pkgs, ... }:

    {
      programs.equibop = {
        enable = true;

        # Discord blocks Discord + VPN + Linux, so pretend we're on
        # Windows until Discord stops being annoying
        package = pkgs.equibop.overrideAttrs (old: {
          postFixup = old.postFixup + ''
            wrapProgram $out/bin/equibop --add-flags "--user-agent-os windows"
          '';
        });

        equicord = {
          themes = {
            "midnight-tokyo-night" = pkgs.fetchurl {
              url = "https://raw.githubusercontent.com/refact0r/midnight-discord/842f3189d295265a17ad56df73326f74d40fbd19/themes/flavors/midnight-tokyo-night.theme.css";
              sha256 = "sha256-sRVvBcpqa7szUlwaPruXixozDdw4EPyAIgAKhJ2xEnk=";
            };
          };

          settings = {
            autoUpdate = true;
            autoUpdateNotification = true;
            useQuickCss = true;
            themeLinks = [ ];
            enabledThemes = [ "midnight-tokyo-night.css" ];

            plugins = {
              BetterSettings.enabled = true;
              BiggerStreamPreview.enabled = true;
              BlurNSFW.enabled = true;
              CallTimer.enabled = true;
              CharacterCounter.enabled = true;
              ClearURLs.enabled = true;
              CrashHandler.enabled = true;
              FakeNitro.enabled = true;
              FixDiscordCss.enabled = true;
              FixImagesQuality.enabled = true;
              FriendInvites.enabled = true;
              GameActivityToggle.enabled = true;
              MessageLogger.enabled = true;
              NoOnboardingDelay.enabled = true;
              PlatformIndicators.enabled = true;
              RevealAllSpoilers.enabled = true;
              ShowHiddenChannels.enabled = true;
              ShowTimeoutDuration.enabled = true;
              SilentTyping.enabled = true;
              TypingIndicator.enabled = true;
              UserVoiceShow.enabled = true;
              ViewIcons.enabled = true;
              WebKeybinds.enabled = true;
              WebScreenShareFixes.enabled = true;

              # preserved from runtime state
              BadgeAPI.enabled = true;
              CommandsAPI.enabled = true;
              MessageAccessoriesAPI.enabled = true;
              NoTrack.enabled = true;
              NoTrack.disableAnalytics = true;
              Settings.enabled = true;
              Settings.settingsLocation = "aboveNitro";
              UserSettingsAPI.enabled = true;
            };
          };
        };
      };
    };
}
