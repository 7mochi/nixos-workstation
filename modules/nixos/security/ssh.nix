_:

{
  flake.modules.nixos.shared = {
    services.openssh = {
      enable = false;
      generateHostKeys = true;
    };
  };
}
