_:

{
  perSystem =
    { config, pkgs, ... }:
    {
      devShells.default = pkgs.mkShell {
        packages =
          (with pkgs; [
            deadnix
            git
            nil
            nixd
            nixfmt
            nix-update
            statix
          ])
          ++ config.pre-commit.settings.enabledPackages;

        shellHook = config.pre-commit.shellHook + ''
          echo "nixos-workstation dev shell"
          echo "  nix fmt          format Nix files"
          echo "  nix flake check  run system and lint checks"
        '';
      };
    };
}
