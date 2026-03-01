{ pkgs, ... }:
{
  programs.cargo = {
    enable = true;
    package = pkgs.emptyDirectory;

    settings = {
      build = {
        jobs = 8;
      };

      alias = {
        b = "build";
        br = "build --release";
        c = "check";
        t = "test";
        r = "run";
        rr = "run --release";
        cl = "clippy";
        cla = "clippy --all-targets --all-features";
        fmt = "fmt --all";
        doc = "doc --open";
      };

      registries.crates-io = {
        protocol = "sparse";
      };
    };
  };
}
