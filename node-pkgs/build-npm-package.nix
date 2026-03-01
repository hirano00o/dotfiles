{ pkgs }:

packageInfo:
let
  inherit (pkgs)
    lib
    stdenv
    fetchurl
    nodejs
    jq
    ;

  fullName =
    if packageInfo ? scope then "${packageInfo.scope}/${packageInfo.pname}" else packageInfo.pname;

  # scopeがある場合は@を%40にエンコード
  urlEncodedName =
    if packageInfo ? scope then
      "${lib.replaceStrings [ "@" ] [ "%40" ] packageInfo.scope}%2F${packageInfo.pname}"
    else
      packageInfo.pname;

  tarballUrl = "https://registry.npmjs.org/${urlEncodedName}/-/${packageInfo.pname}-${packageInfo.version}.tgz";

in
stdenv.mkDerivation rec {
  pname = packageInfo.pname;
  version = packageInfo.version;

  src = fetchurl {
    url = tarballUrl;
    hash = packageInfo.tarballHash;
  };

  nativeBuildInputs = [ jq ];
  buildInputs = [ nodejs ];

  dontBuild = true;

  installPhase = ''
        runHook preInstall

        mkdir -p $out/lib/node_modules/${pname}
        cp -r * $out/lib/node_modules/${pname}/

        # package.jsonからbinフィールドを読み取ってシンボリックリンクを作成
        if [ -f $out/lib/node_modules/${pname}/package.json ]; then
          cd $out/lib/node_modules/${pname}

          BIN_ENTRIES=$(jq -r '.bin | to_entries[] | "\(.key):\(.value)"' package.json 2>/dev/null || echo "")

          if [ -n "$BIN_ENTRIES" ]; then
            mkdir -p $out/bin

            # 各binエントリーに対してラッパースクリプトを作成
            while IFS=: read -r bin_name bin_path; do
              # bin_pathの先頭の./を削除
              bin_path="''${bin_path#./}"

              # renameBinが指定されている場合は名前を変更
              ${lib.optionalString (packageInfo ? renameBin) ''
                ${lib.concatStringsSep "\n" (
                  lib.mapAttrsToList (from: to: ''
                    if [ "$bin_name" = "${from}" ]; then
                      bin_name="${to}"
                    fi
                  '') packageInfo.renameBin
                )}
              ''}

              cat > $out/bin/$bin_name << EOF
    #!/usr/bin/env node
    import('file://$out/lib/node_modules/${pname}/$bin_path');
    EOF
              chmod +x $out/bin/$bin_name
            done <<< "$BIN_ENTRIES"
          fi
        fi

        runHook postInstall
  '';

  meta = with lib; {
    description = "${pname} - npm package";
    homepage = "https://www.npmjs.com/package/${fullName}";
    license = licenses.mit;
    mainProgram = packageInfo.mainProgram or pname;
    platforms = platforms.all;
  };
}
