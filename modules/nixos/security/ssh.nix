_:

{
  flake.modules.nixos.shared = {
    services.openssh = {
      enable = false;

      settings = {
        KbdInteractiveAuthentication = false;
        PasswordAuthentication = false;
        PermitRootLogin = "no";
      };
    };
  };
}
