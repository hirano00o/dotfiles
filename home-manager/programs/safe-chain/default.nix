{
  pkgs,
  lib,
  config,
  ...
}:
let
  safe-chain = import ../../packages/safe-chain { inherit pkgs; };
  initScript = "${config.home.homeDirectory}/.safe-chain/scripts/init-posix.sh";
in
{
  home.packages = [ safe-chain ];

  # safe-chain setupを実行してスクリプト(~/.safe-chain/scripts/init-posix.sh)を生成
  home.activation.safe-chain-setup = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if [ ! -f ${initScript} ]; then
      verboseEcho "Running safe-chain setup to generate init scripts..."
      run ${safe-chain}/bin/safe-chain setup 2>/dev/null || true
    fi
  '';

  programs.zsh.initContent = lib.mkAfter ''
    # Safe-chain initialization
    [ -f ${initScript} ] && source ${initScript}
  '';
}
