{ inputs, ... }:

{
  flake.modules.nixos.kernel =
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
