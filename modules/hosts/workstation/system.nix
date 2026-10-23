_:

{
  flake.modules.nixos.workstation-system = {
    networking.hostName = "workstation";
    system.stateVersion = "26.05";
  };
}
