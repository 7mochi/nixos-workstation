{
  flake.modules.homeManager.keepassxc =
    { pkgs, ... }:

    {
      programs.keepassxc.enable = true;

      programs.zen-browser.nativeMessagingHosts = [ pkgs.keepassxc ];
    };
}
