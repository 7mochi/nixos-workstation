_:

{
  flake.modules.nixos.vm = {
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
