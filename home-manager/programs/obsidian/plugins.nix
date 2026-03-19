# plugins.nix
#
# Defines mkObsidianPlugin helper and Obsidian community plugin packages.
#
# Each plugin is fetched from its GitHub release and installed into $out/ so
# that home-manager's communityPlugins option can symlink the files into the
# vault's .obsidian/plugins/<id>/ directory.
#
# Usage:
#   let obsidianPlugins = import ./plugins.nix { inherit pkgs; };
#   in obsidianPlugins.dataview
{ pkgs }:
let
  inherit (pkgs) lib;

  # mkObsidianPlugin fetches main.js, manifest.json, and optionally styles.css
  # from a GitHub release and places them under $out/.
  #
  # Arguments:
  #   pname        - Plugin package name used as the Nix derivation name
  #   version      - Release tag / version string
  #   repo         - GitHub repository in "owner/name" format
  #   mainHash     - SRI hash (sha256-...) for main.js
  #   manifestHash - SRI hash (sha256-...) for manifest.json
  #   hasStyles    - Whether styles.css exists in the release (default: true)
  #   stylesHash   - SRI hash (sha256-...) for styles.css (required when hasStyles = true)
  #
  # Example:
  #   mkObsidianPlugin {
  #     pname = "obsidian-dataview";
  #     version = "0.5.68";
  #     repo = "blacksmithgu/obsidian-dataview";
  #     mainHash = "sha256-eU6ert5zkgu41UsO2k9d4hgtaYzGOHdFAPJPFLzU2gs=";
  #     manifestHash = "sha256-kjXbRxEtqBuFWRx57LmuJXTl5yIHBW6XZHL5BhYoYYU=";
  #     hasStyles = true;
  #     stylesHash = "sha256-MwbdkDLgD5ibpyM6N/0lW8TT9DQM7mYXYulS8/aqHek=";
  #   }
  mkObsidianPlugin =
    {
      pname,
      version,
      repo,
      mainHash,
      manifestHash,
      hasStyles ? true,
      stylesHash ? "",
    }:
    let
      baseUrl = "https://github.com/${repo}/releases/download/${version}";
      mainJs = pkgs.fetchurl {
        url = "${baseUrl}/main.js";
        hash = mainHash;
        name = "main.js";
      };
      manifestJson = pkgs.fetchurl {
        url = "${baseUrl}/manifest.json";
        hash = manifestHash;
        name = "manifest.json";
      };
      stylesCss = lib.optional hasStyles (
        pkgs.fetchurl {
          url = "${baseUrl}/styles.css";
          hash = stylesHash;
          name = "styles.css";
        }
      );
    in
    pkgs.stdenvNoCC.mkDerivation {
      inherit pname version;
      srcs = [
        mainJs
        manifestJson
      ]
      ++ stylesCss;

      # Disable phases that are not needed for simple file installation.
      dontUnpack = true;
      dontBuild = true;
      dontFixup = true;

      # Install all fetched files directly into $out/.
      installPhase = ''
        runHook preInstall
        mkdir -p "$out"
        cp ${mainJs} "$out/main.js"
        cp ${manifestJson} "$out/manifest.json"
        ${lib.optionalString hasStyles ''cp ${builtins.head stylesCss} "$out/styles.css"''}
        runHook postInstall
      '';
    };

  #
  # Plugin definitions
  #

  remotelySave = mkObsidianPlugin {
    pname = "remotely-save";
    version = "0.5.25";
    repo = "fyears/remotely-save";
    mainHash = "sha256-s6+9J/FRiLl4RhjJWGB4abqkNNwKvPByd0+ZNiwR+gQ=";
    manifestHash = "sha256-cdnAthYAPzppaIDnqogpblsxVVdX6TOhLSkAuWxMqpA=";
    hasStyles = true;
    stylesHash = "sha256-h1hOfVOMpYxSevuyYlsJ6igryue/eEt8zjPKkung37M=";
  };

  noteArchiver = mkObsidianPlugin {
    pname = "note-archiver";
    version = "0.1.0";
    repo = "thenomadlad/obsidian-note-archiver";
    mainHash = "sha256-3wIaF33CEBsT0dFsi/qA/kDMio8eyRxdbfx+k2Mi4lI=";
    manifestHash = "sha256-OrVPIOtsgFcXk0zaM8JSNb610NQiFuwuhduz/HZp7yo=";
    hasStyles = true;
    stylesHash = "sha256-1L6KtzSlO7fyqZd1Vt9nbmYCYKS318Bbj7DD1rcZzI4=";
  };

  checklistPlugin = mkObsidianPlugin {
    pname = "obsidian-checklist-plugin";
    version = "2.2.14";
    repo = "delashum/obsidian-checklist-plugin";
    mainHash = "sha256-V70MtgxChT+IukUNx0v9pABbMnydIAXdp3tzA38XJbI=";
    manifestHash = "sha256-NGrEvH0ipK1664/h7KHctWxjWhZWB2nOF6cJc1n9mJg=";
    hasStyles = true;
    stylesHash = "sha256-qmP8GTmmN8oEoxkr8HIw4kgH/QtVnNHgCc9jRSlemFc=";
  };

  cmEditorSyntaxHighlight = mkObsidianPlugin {
    pname = "cm-editor-syntax-highlight-obsidian";
    version = "0.1.3";
    repo = "deathau/cm-editor-syntax-highlight-obsidian";
    mainHash = "sha256-3nM3xnQs/JneecQbX66O8IXw1DZcQU8riF5qaSxiPw8=";
    manifestHash = "sha256-CqHc2LPcAb1t4PE5k5FsoEwqkd+iYZqg7+gj1/YGBEo=";
    hasStyles = true;
    stylesHash = "sha256-P2eaQQvyqaVQISq1zvhepPRrhlWDg49VsSgu+SVkx3k=";
  };

  advancedUri = mkObsidianPlugin {
    pname = "obsidian-advanced-uri";
    version = "1.46.0";
    repo = "Vinzent03/obsidian-advanced-uri";
    mainHash = "sha256-OG6BQqtCR1gy2WV9l6fbF6Oupf2bZ+XrAJ7NBBMMN6w=";
    manifestHash = "sha256-bCAROasWK0ALyupygo0SBdInPrIDTvMHVSIVDIZ4jzo=";
    hasStyles = false;
  };

  excalidrawPlugin = mkObsidianPlugin {
    pname = "obsidian-excalidraw-plugin";
    version = "2.17.2";
    repo = "zsviczian/obsidian-excalidraw-plugin";
    mainHash = "sha256-Ph99qvddCyCM4eYKYG00xwRcqk4ODLHoggSb+wLbzII=";
    manifestHash = "sha256-/cgKjZqS+9R7BR8vc4LpaHrH/QEhZqbP2PLTGKR1fVo=";
    hasStyles = true;
    stylesHash = "sha256-xmFLOnPOgLvXMt+o5Z8zCaWA/g8LZ5hpzFA7PzQPwjY=";
  };

  kanban = mkObsidianPlugin {
    pname = "obsidian-kanban";
    version = "2.0.51";
    repo = "mgmeyers/obsidian-kanban";
    mainHash = "sha256-p+O9TPJfm39TqEHETOmQ2w7195VOvKsXrm3KgDEMOaw=";
    manifestHash = "sha256-JJdnhwl+rUZ5aeAUo1ZU56gOTbSal3aJpIr636FeGFQ=";
    hasStyles = true;
    stylesHash = "sha256-7PbdMfFyfEQczm9UeUsNORbc//yH+he4VceboEqF2ac=";
  };

  dataview = mkObsidianPlugin {
    pname = "obsidian-dataview";
    version = "0.5.68";
    repo = "blacksmithgu/obsidian-dataview";
    mainHash = "sha256-eU6ert5zkgu41UsO2k9d4hgtaYzGOHdFAPJPFLzU2gs=";
    manifestHash = "sha256-kjXbRxEtqBuFWRx57LmuJXTl5yIHBW6XZHL5BhYoYYU=";
    hasStyles = true;
    stylesHash = "sha256-MwbdkDLgD5ibpyM6N/0lW8TT9DQM7mYXYulS8/aqHek=";
  };

  terminal = mkObsidianPlugin {
    pname = "obsidian-terminal";
    version = "3.20.0";
    repo = "polyipseity/obsidian-terminal";
    mainHash = "sha256-s1sLCVlzX/2IsLESF/GdFgBbQnJmyYbD25jAdNwN7Zk=";
    manifestHash = "sha256-IQ5tkBYRw8K3g3EnBnE1fNdSEdpLhAoZSQhbfXgFf5s=";
    hasStyles = true;
    stylesHash = "sha256-J9U7w2XyKZ6A89N79Uy0XthQPoARavIxfXmmTlnlnHw=";
  };
in
{
  # Export individual plugins so they can be referenced in default.nix.
  inherit
    remotelySave
    noteArchiver
    checklistPlugin
    cmEditorSyntaxHighlight
    advancedUri
    excalidrawPlugin
    kanban
    dataview
    terminal
    ;
}
