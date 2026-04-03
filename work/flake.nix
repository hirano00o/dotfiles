{
  description = "Xanadu used packages";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    nixpkgs-python311pip.url = "github:nixos/nixpkgs/8ad5e8132c5dcf977e308e7bf5517cc6cc0bf7d8";
    flake-utils.url = "github:numtide/flake-utils";
    generate-luida-hearingsheet = {
      url = "git+ssh://git@github.com/dentsudigital/generate-luida-hearingsheet";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    pjwt-src = {
      url = "git+ssh://git@github.com/dentsudigital/pjwt.git?ref=refs/tags/v1.0.1";
      flake = false;
    };
    dybw-src = {
      url = "git+ssh://git@github.com/dentsudigital/dybw.git?ref=refs/tags/v0.0.3";
      flake = false;
    };
    account-permission-for-dybw-generator-src = {
      url = "git+ssh://git@github.com/dentsudigital/account-permission-for-dybw-generator.git";
      flake = false;
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      nixpkgs-python311pip,
      flake-utils,
      generate-luida-hearingsheet,
      pjwt-src,
      dybw-src,
      account-permission-for-dybw-generator-src,
      ...
    }:
    let
      overlays = import ./overlays { inherit nixpkgs-python311pip; };

      packagesOutputs = flake-utils.lib.eachDefaultSystem (
        system:
        let
          pkgs = import nixpkgs {
            inherit system;
            overlays = [
              overlays.python311-pip
              overlays.terraform
            ];
            config.allowUnfree = true;
          };
        in
        import ./packages {
          inherit
            self
            pkgs
            system
            pjwt-src
            dybw-src
            account-permission-for-dybw-generator-src
            generate-luida-hearingsheet
            ;
        }
      );
    in
    packagesOutputs;
}
