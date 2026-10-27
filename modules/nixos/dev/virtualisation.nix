_:

{
  flake.modules.nixos.virtualisation =
    {
      config,
      lib,
      pkgs,
      ...
    }:

    let
      kernel = config.boot.kernelPackages.kernel;
      # patchelf 0.19.2 corrupts VMware's userspace binaries (PHDR not covered
      # by a LOAD segment), making vmnet-natd crash at startup. Pin 0.15.2
      # until https://github.com/NixOS/patchelf/issues/674 is fixed, same
      # workaround as https://github.com/NixOS/nixpkgs/pull/576879.
      patchelf_0_15_2 = pkgs.patchelf.overrideAttrs (
        finalAttrs: _: {
          version = "0.15.2";
          src = pkgs.fetchurl {
            url = "https://github.com/NixOS/patchelf/releases/download/${finalAttrs.version}/patchelf-${finalAttrs.version}.tar.bz2";
            hash = "sha256-F3RfVkFZyOIo/EEtplogSLhGxLa0Igt3y/IkFuAvLXw=";
          };
        }
      );
      vmwarePackage = pkgs.vmware-workstation.overrideAttrs (old: {
        nativeBuildInputs = [ patchelf_0_15_2 ] ++ (old.nativeBuildInputs or [ ]);
      });
      vmwareModules = config.boot.kernelPackages.vmware.overrideAttrs (old: {
        nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [ pkgs.kmodigest ];
        postInstall = (old.postInstall or "") + ''
          for module in $out/lib/modules/${kernel.modDirVersion}/misc/*.ko; do
            kmodigest "$module"
          done
        '';
      });
    in
    {
      # The module aggregator expects .ko.cer files, but vmware installs its
      # modules without going through the Kbuild signing path
      # https://github.com/NixOS/nixpkgs/issues/575192
      # Upstream fix in progress: https://github.com/NixOS/nixpkgs/pull/578004
      boot.extraModulePackages = lib.mkForce [ vmwareModules ];

      virtualisation = {
        libvirtd = {
          enable = true;
          qemu.swtpm.enable = true;
        };
        spiceUSBRedirection.enable = true;

        vmware.host = {
          enable = true;
          package = vmwarePackage;
        };
      };

      programs.virt-manager.enable = true;

      environment.etc."virtio-win.iso".source = pkgs.virtio-win.src;
    };
}
