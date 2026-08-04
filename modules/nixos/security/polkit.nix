_:

{
  flake.modules.nixos.shared = {
    networking.firewall.enable = true;
    security.polkit.enable = true;
  };
}
