_:

{
  flake.modules.homeManager.shared = {
    home.file.".config/opencode/opencode.json".text = ''
      {
        "$schema": "https://opencode.ai/config.json",
        "provider": {
          "opencode": {
            "options": { "apiKey": "{file:/run/secrets/opencode-api-key}" }
          }
        }
      }
    '';
  };
}
