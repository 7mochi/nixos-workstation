_:

{
  flake.modules.nixos.workstation = {
    time.timeZone = "America/Lima";
    i18n.defaultLocale = "en_US.UTF-8";

    console = {
      font = "Lat2-Terminus16";
      keyMap = "us";
    };
  };
}
