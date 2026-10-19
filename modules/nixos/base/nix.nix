{ inputs, ... }:

let
  nixSettings = import ../../../lib/nix-settings.nix;
  identity = import ../../../lib/identity.nix;
in
{
  flake.modules.nixos.shared =
    { pkgs, ... }:

    {
      nixpkgs.config.allowUnfreePredicate =
        pkg:
        builtins.elem (pkgs.lib.getName pkg) [
          "intellij-idea"
          "intellij-idea-with-plugins"
          "obsidian"
          "rider"
          "rider-with-plugins"
          "steam"
          "steam-run"
          "steam-unwrapped"
          "stremio-linux-shell"
          "vscode"
          "unrar"
          "vmware-workstation"
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
            identity.username
          ];

          inherit (nixSettings) substituters;

          trusted-public-keys = nixSettings.trustedPublicKeys;

          fallback = true;
          connect-timeout = 5;

          auto-optimise-store = false;
          max-jobs = 4;
          cores = 0;
          keep-outputs = true;
        };

        gc.automatic = false;

        optimise = {
          automatic = true;
          dates = [ "03:45" ];
        };
      };

      documentation.nixos.enable = false;

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
