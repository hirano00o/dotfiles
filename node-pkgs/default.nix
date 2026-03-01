{ pkgs }:

let
  buildNpmPkg = import ./build-npm-package.nix { inherit pkgs; };
  packagesList = import ./packages.nix;
in
builtins.listToAttrs (
  map (pkg: {
    name = pkg.pname;
    value = buildNpmPkg pkg;
  }) packagesList
)
