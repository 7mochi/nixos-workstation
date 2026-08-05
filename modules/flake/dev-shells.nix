_:

{
  perSystem =
    { pkgs, ... }:
    {
      devShells.default = pkgs.mkShell {
        packages = with pkgs; [
          deadnix
          git
          nil
          nixd
          nixfmt
          nix-update
          statix
        ];

        shellHook = ''
          echo "nixos-workstation dev shell"
          echo "  nix fmt          format Nix files"
          echo "  nix flake check  run system and lint checks"
        '';
      };
    };
}
