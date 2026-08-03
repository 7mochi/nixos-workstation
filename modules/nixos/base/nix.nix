{ inputs, ... }:

{
  flake.modules.nixos.workstation =
    { pkgs, ... }:

    {
      nixpkgs.config.allowUnfreePredicate =
        pkg:
        builtins.elem (pkgs.lib.getName pkg) [
          "obsidian"
          "steam"
          "steam-unwrapped"
          "vscode"
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
          ];

          trusted-public-keys = [
            "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
            "niri.cachix.org-1:Wv0OmO7PsuocRKzfDoJ3mulSl7Z6oezYhGhR+3W2964="
            "noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="
          ];

          auto-optimise-store = true;
        };

        gc = {
          automatic = true;
          dates = "weekly";
          options = "--delete-older-than 7d";
        };
      };
    };
}
