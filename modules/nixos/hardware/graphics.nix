_:

{
  flake.modules.nixos.shared = {
    hardware.graphics = {
      enable = true;
      enable32Bit = true;
    };
  };
}
