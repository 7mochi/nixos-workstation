_:

{
  flake.modules.homeManager.commandcode = {
    home.file.".commandcode/mcp.json" = {
      force = true;
      text = ''
        {
          "mcpServers": {
            "rea": {
              "transport": "stdio",
              "enabled": true,
              "command": "npx",
              "args": ["-y", "rea-agents@6.8.0", "mcp"]
            }
          }
        }
      '';
    };
  };
}
