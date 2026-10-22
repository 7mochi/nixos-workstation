_:

{
  flake.modules.nixos.ssh = {
    services.openssh = {
      enable = false;
      generateHostKeys = true;
    };
  };
}
