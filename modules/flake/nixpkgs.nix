{ inputs, lib, ... }:

let
  pkgsPolicy = import ../../lib/pkgs-policy.nix { inherit lib; };
in
{
  # This override replaces the `pkgs` argument for EVERY perSystem module
  # (packages, checks, formatter, devShells), not only `packages`, and it does
  # NOT include the system host overlays. It lives in its own file so nobody
  # has to read packages.nix to learn which package set the flake evaluates
  # against.
  perSystem =
    { system, ... }:
    {
      _module.args.pkgs = import inputs.nixpkgs {
        inherit system;
        config = {
          allowUnfreePredicate = pkgsPolicy.predicate pkgsPolicy.perSystem;
        };
      };
    };
}
