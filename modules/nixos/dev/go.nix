_:

{
  flake.modules.nixos.go =
    { pkgs, ... }:

    {
      environment.systemPackages = with pkgs; [
        # Go toolchain and language server.
        go
        gopls

        # Debugging and linting (VSCode Go extension).
        delve
        golangci-lint
      ];
    };
}
