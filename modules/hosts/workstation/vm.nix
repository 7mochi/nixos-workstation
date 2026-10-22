_:

{
  flake.modules.nixos.workstation = {
    virtualisation.vmVariant = {
      virtualisation = {
        memorySize = 8192;
        cores = 4;
        diskSize = 40960;
        graphics = true;
      };
    };
  };
}
