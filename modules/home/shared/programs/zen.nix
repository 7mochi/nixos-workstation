{ inputs, ... }:

{
  flake.modules.homeManager.shared =
    { pkgs, ... }:

    let
      firefox-addons = inputs.firefox-addons.packages.${pkgs.stdenv.hostPlatform.system};
    in
    {
      programs.zen-browser = {
        enable = true;
        setAsDefaultBrowser = true;

        policies.ExtensionSettings = {
          "{76ef94a4-e3d0-4c6f-961a-d38a429a332b}" = {
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/ttv-lol-pro/ttv-lol-pro.xpi";
            installation_mode = "force_installed";
          };
          "user-agent-switcher@ninetailed.ninja" = {
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/uaswitcher/uaswitcher.xpi";
            installation_mode = "force_installed";
          };
          "{6e3f516b-0653-4d26-87c5-bc71749229ee}" = {
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/pp-calculator/pp-calculator.xpi";
            installation_mode = "force_installed";
          };
          "cavitedev@gmail.com" = {
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/osu-subdivide-nations/osu-subdivide-nations.xpi";
            installation_mode = "force_installed";
          };
          "{149e2c13-2556-4e9f-ad37-05ccb2f8676d}" = {
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/chatgpt-export/chatgpt-export.xpi";
            installation_mode = "force_installed";
          };
        };

        profiles.default = {
          extensions.packages = with firefox-addons; [
            ublock-origin
            stylus
            yomitan
            sponsorblock
            return-youtube-dislikes
            react-devtools
            violentmonkey
            zen-internet
          ];
        };
      };
    };
}
