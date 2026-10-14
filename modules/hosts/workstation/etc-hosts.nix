_:

{
  flake.modules.nixos.workstation = {
    networking.hosts = {
      "127.0.0.1" = [
        "bancho.local"
        "a.bancho.local"
        "api.bancho.local"
        "assets.bancho.local"
        "b.bancho.local"
        "c.bancho.local"
        "c4.bancho.local"
        "ce.bancho.local"
        "i.bancho.local"
        "osu.bancho.local"
        "s.bancho.local"
      ];
    };
  };
}
