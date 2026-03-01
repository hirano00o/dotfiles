{ ... }:
{
  imports = [
    ./default.nix
  ];

  homebrew = {
    casks = [
      "windows-app"
    ];
  };
}
