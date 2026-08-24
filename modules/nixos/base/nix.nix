{ inputs, ... }:

{
  flake.modules.nixos.shared =
    { pkgs, ... }:

    {
      nixpkgs.config.allowUnfreePredicate =
        pkg:
        builtins.elem (pkgs.lib.getName pkg) [
          "idea"
          "obsidian"
          "steam"
          "steam-run"
          "steam-unwrapped"
          "stremio-linux-shell"
          "vscode"
          "wootility"
        ];

      nix = {
        registry.nixpkgs.flake = inputs.nixpkgs;

        settings = {
          experimental-features = [
            "nix-command"
            "flakes"
          ];

          trusted-users = [
            "root"
            "nanamochi"
          ];

          substituters = [
            "https://cache.nixos.org/"
            "https://niri.cachix.org"
            "https://noctalia.cachix.org"
            "https://cache.xinux.uz"
          ];

          trusted-public-keys = [
            "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
            "niri.cachix.org-1:Wv0OmO7PsuocRKzfDoJ3mulSl7Z6oezYhGhR+3W2964="
            "noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="
            "cache.xinux.uz:BXCrtqejFjWzWEB9YuGB7X2MV4ttBur1N8BkwQRdH+0="
          ];

          auto-optimise-store = true;
        };

        gc.automatic = false;
      };

      programs.nh = {
        enable = true;
        clean = {
          enable = true;
          dates = "daily";
          extraArgs = "--keep 5 --no-gcroots";
        };
      };
    };
}
