_:

{
  flake.modules.homeManager.shared = {
    home.sessionVariables.SUPERPOWERS_DISABLE_TELEMETRY = "true";

    xdg.configFile = {
      "opencode/opencode.json".text = ''
        {
          "$schema": "https://opencode.ai/config.json",
          "plugin": [
            "superpowers@git+https://github.com/obra/superpowers.git"
          ],
          "provider": {
            "opencode": {
              "options": { "apiKey": "{file:/run/secrets/opencode-api-key}" }
            },
            "commandcode": {
              "npm": "@ai-sdk/openai-compatible",
              "name": "CommandCode AI",
              "options": {
                "baseURL": "https://api.commandcode.ai/provider/v1",
                "headers": {
                  "Authorization": "Bearer {file:/run/secrets/commandcode-api-key}"
                }
              },
              "models": {
                "claude-sonnet-5": { "name": "Claude Sonnet 5" },
                "claude-sonnet-4-6": { "name": "Claude Sonnet 4.6" },
                "claude-fable-5": { "name": "Claude Fable 5" },
                "claude-opus-5": { "name": "Claude Opus 5" },
                "claude-opus-4-8": { "name": "Claude Opus 4.8" },
                "claude-opus-4-7": { "name": "Claude Opus 4.7" },
                "claude-haiku-4-5-20251001": { "name": "Claude Haiku 4.5" },
                "gpt-5.6-sol": { "name": "GPT-5.6 Sol" },
                "gpt-5.6-terra": { "name": "GPT-5.6 Terra" },
                "gpt-5.6-luna": { "name": "GPT-5.6 Luna" },
                "gpt-5.5": { "name": "GPT-5.5" },
                "gpt-5.4": { "name": "GPT-5.4" },
                "gpt-5.3-codex": { "name": "GPT-5.3 Codex" },
                "gpt-5.4-mini": { "name": "GPT-5.4 Mini" },
                "deepseek/deepseek-v4-pro": { "name": "DeepSeek V4 Pro (latest)" },
                "deepseek/deepseek-v4-flash": { "name": "DeepSeek V4 Flash (latest)" },
                "moonshotai/Kimi-K3": { "name": "Kimi K3" },
                "moonshotai/Kimi-K2.7-Code": { "name": "Kimi K2.7 Code" },
                "moonshotai/Kimi-K2.7-Code-Highspeed": { "name": "Kimi K2.7 Code HighSpeed" },
                "moonshotai/Kimi-K2.6": { "name": "Kimi K2.6" },
                "moonshotai/Kimi-K2.5": { "name": "Kimi K2.5" },
                "zai-org/GLM-5.3": { "name": "GLM-5.3" },
                "zai-org/GLM-5.2": { "name": "GLM-5.2" },
                "zai-org/GLM-5.2-Fast": { "name": "GLM-5.2 Fast" },
                "zai-org/GLM-5.1": { "name": "GLM-5.1" },
                "zai-org/GLM-5": { "name": "GLM-5" },
                "MiniMaxAI/MiniMax-M3": { "name": "MiniMax M3" },
                "MiniMaxAI/MiniMax-M2.7": { "name": "MiniMax M2.7" },
                "MiniMaxAI/MiniMax-M2.5": { "name": "MiniMax M2.5" },
                "xiaomi/mimo-v2.5-pro": { "name": "MiMo V2.5 Pro" },
                "xiaomi/mimo-v2.5": { "name": "MiMo V2.5" },
                "Qwen/Qwen3.8-Max": { "name": "Qwen 3.8 Max" },
                "Qwen/Qwen3.8-27B": { "name": "Qwen 3.8 27B" },
                "Qwen/Qwen3.7-Max": { "name": "Qwen 3.7 Max" },
                "Qwen/Qwen3.7-Plus": { "name": "Qwen 3.7 Plus" },
                "Qwen/Qwen3.7-Flash": { "name": "Qwen 3.7 Flash" },
                "Qwen/Qwen3.6-Max-Preview": { "name": "Qwen 3.6 Max Preview" },
                "Qwen/Qwen3.6-Plus": { "name": "Qwen 3.6 Plus" },
                "stepfun/Step-3.7-Flash": { "name": "Step 3.7 Flash" },
                "stepfun/Step-3.5-Flash": { "name": "Step 3.5 Flash" },
                "tencent/hy3-paid": { "name": "Tencent Hy3" },
                "google/gemini-3.7-flash": { "name": "Gemini 3.7 Flash" },
                "google/gemini-3.6-flash": { "name": "Gemini 3.6 Flash" },
                "google/gemini-3.5-flash": { "name": "Gemini 3.5 Flash" },
                "google/gemini-3.5-flash-lite": { "name": "Gemini 3.5 Flash Lite" },
                "google/gemini-3.1-flash-lite": { "name": "Gemini 3.1 Flash Lite" },
                "sakana/fugu-ultra": { "name": "Fugu Ultra" },
                "nvidia/nemotron-3-ultra-550b-a55b": { "name": "Nemotron 3 Ultra" },
                "thinkingmachines/inkling": { "name": "Inkling" },
                "thinkingmachines/inkling-small": { "name": "Inkling Small" },
                "poolside/laguna-s-2.1-free": { "name": "Laguna S 2.1" },
                "meta/muse-spark-1.1": { "name": "Muse Spark 1.1" },
                "meta/muse-spark-1.2": { "name": "Muse Spark 1.2" },
                "meta/muse-spark-1.2-contributor": { "name": "Muse Spark 1.2 Contributor" },
                "xai/grok-4.5": { "name": "Grok 4.5" },
                "xai/grok-4.6": { "name": "Grok 4.6" }
              }
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
