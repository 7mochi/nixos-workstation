_:

{
  flake.modules.nixos.shared = {
    services.openssh = {
      enable = false;

      generateHostKeys = true;

      settings = {
        KbdInteractiveAuthentication = false;
        PasswordAuthentication = false;
        PermitRootLogin = "no";
      };
    };
  };
}
