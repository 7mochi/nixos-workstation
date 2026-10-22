{ inputs, ... }:

{
  imports = [ inputs.treefmt-nix.flakeModule ];

  perSystem = _: {
    treefmt = {
      projectRootFile = "flake.nix";

      programs = {
        nixfmt.enable = true;
        deadnix = {
          enable = true;
          no-lambda-pattern-names = true;
        };
        statix.enable = true;
        fish_indent.enable = true;
        kdlfmt.enable = true;
      };
    };
  };
}
