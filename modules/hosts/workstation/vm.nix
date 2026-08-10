_:

{
  flake.modules.nixos.workstation =
    { pkgs, ... }:

    {
      virtualisation.libvirtd.enable = true;
      programs.virt-manager.enable = true;
      environment.systemPackages = [ pkgs.dnsmasq ];

      services.samba = {
        enable = true;
        openFirewall = true;

        settings = {
          global = {
            "security" = "user";
            "guest account" = "nobody";
            "map to guest" = "bad user";
            "server min protocol" = "NT1";
          };

          shared = {
            path = "/media/hdd/shared";
            browseable = "yes";
            "read only" = "no";
            "guest ok" = "yes";
            "create mask" = "0644";
            "directory mask" = "0755";
            "force user" = "nanamochi";
            "force group" = "users";
          };
        };
      };

      networking.firewall.trustedInterfaces = [ "virbr0" ];

      systemd.tmpfiles.settings."10-shared"."/media/hdd/shared".d = {
        mode = "0777";
        user = "root";
        group = "root";
      };

      users.users.nanamochi.extraGroups = [ "libvirtd" ];
    };
}
