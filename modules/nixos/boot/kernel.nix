_:

{
  flake.modules.nixos.workstation =
    { pkgs, ... }:

    {
      boot = {
        kernelPackages = pkgs.cachyosKernels.linuxPackages-cachyos-bore;
      };
    };
}
