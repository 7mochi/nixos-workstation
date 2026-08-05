_:

{
  flake.modules.homeManager.shared = {
    xdg.configFile = {
      "opencode/opencode.json".text = ''
        {
          "$schema": "https://opencode.ai/config.json",
          "provider": {
            "opencode": {
              "options": { "apiKey": "{file:/run/secrets/opencode-api-key}" }
            }
          }
        }
      '';

      "opencode/tui.json".text = ''
        {
          "$schema": "https://opencode.ai/tui.json",
          "theme": "tokyonight"
        }
      '';
    };
  };
}
