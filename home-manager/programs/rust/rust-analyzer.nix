{ ... }:
{
  home.file.".config/rust-analyzer/config.toml".text = ''
    [checkOnSave]
    command = "clippy"

    [cargo]
    allFeatures = true

    [procMacro]
    enable = true

    [assist]
    importGranularity = "module"

    [diagnostics]
    enable = true
    experimental.enable = true
  '';
}
