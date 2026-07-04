{ ... }:
{
  # golangci-lint はプロジェクト → 上位ディレクトリ → ホームの順で設定を探索する。
  # 設定を持たないリポジトリ向けのフォールバックとして配備する (lang-go スキルの前提)。
  home.file.".golangci.yml".source = ./golangci.yml;
}
