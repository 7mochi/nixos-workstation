{
  flake.modules.nixos.samba =
    { identity, ... }:

    let
      sharePath = "${identity.homeDirectory}/Shared";
    in
    {
      services.samba = {
        enable = true;
        settings = {
          global = {
            "server min protocol" = "NT1";
            "ntlm auth" = "yes";
            "map to guest" = "Bad User";
            "hosts allow" = "192.168.122. 127.0.0.1";
            "hosts deny" = "0.0.0.0/0";
          };

          shared = {
            path = sharePath;
            browseable = "yes";
            "read only" = "no";
            "guest ok" = "yes";
            "force user" = identity.username;
            "force group" = "users";
            "create mask" = "0644";
            "directory mask" = "0755";
          };
        };
      };

      networking.firewall.interfaces.virbr0 = {
        allowedTCPPorts = [
          139
          445
        ];
        allowedUDPPorts = [
          137
          138
        ];
      };

      systemd.tmpfiles.rules = [ "d ${sharePath} 0755 ${identity.username} users -" ];
    };
}
