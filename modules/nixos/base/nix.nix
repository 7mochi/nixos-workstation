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
