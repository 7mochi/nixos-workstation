_:

{
  flake.modules.homeManager.niri-startup = {
    programs.niri.settings.spawn-at-startup = [
      { command = [ "noctalia" ]; }
    ];
  };
}
