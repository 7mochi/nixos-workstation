{ inputs, ... }:

{
  imports = [ inputs.git-hooks.flakeModule ];

  perSystem = _: {
    pre-commit.settings.hooks = {
      treefmt.enable = true;
      markdownlint = {
        enable = true;
        settings.configuration.MD013 = false;
      };
    };
  };
}
