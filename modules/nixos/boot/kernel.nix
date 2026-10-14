{ inputs, ... }:

{
  flake.modules.nixos.shared =
    { pkgs, ... }:

    {
      nixpkgs.overlays = [
        inputs.nix-cachyos-kernel.overlays.pinned
      ];

      boot = {
        kernelPackages = pkgs.cachyosKernels.linuxPackages-cachyos-bore;
      };
    };
}
