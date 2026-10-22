_:

{
  flake.modules.nixos.virtualisation =
    { pkgs, ... }:

    {
      virtualisation = {
        libvirtd = {
          enable = true;
          qemu.swtpm.enable = true;
        };
        spiceUSBRedirection.enable = true;

        vmware.host.enable = true;
      };

      programs.virt-manager.enable = true;

      environment.etc."virtio-win.iso".source = pkgs.virtio-win.src;
    };
}
