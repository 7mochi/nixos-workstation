_:

{
  flake.modules.nixos.shared =
    { pkgs, ... }:

    {
      boot = {
        kernelPackages = pkgs.cachyosKernels.linuxPackages-cachyos-bore;
      };
    };
}
