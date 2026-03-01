{ ... }:
{
  imports = [
    ./default.nix
  ];

  homebrew = {
    casks = [
      "grishka/grishka/neardrop"
    ];
  };
}
