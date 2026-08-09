_:

{
  flake.modules.homeManager.shared =
    { pkgs, ... }:

    {
      programs.vesktop = {
        enable = true;

        # Discord blocks Discord + VPN + Linux, so pretend we're on
        # Windows until Discord stops being annoying
        package = pkgs.vesktop.overrideAttrs (old: {
          postFixup = old.postFixup + ''
            wrapProgram $out/bin/vesktop --add-flags "--user-agent-os windows"
          '';
        });

        vencord = {
          themes = {
            "midnight-tokyo-night" = pkgs.fetchurl {
              url = "https://raw.githubusercontent.com/refact0r/midnight-discord/refs/heads/master/themes/flavors/midnight-tokyo-night.theme.css";
              sha256 = "0lyfqnf76fwpd5f2qgg1xzgdd4j9s0fvjaj2wxwhcqkc0bs7syvg";
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
