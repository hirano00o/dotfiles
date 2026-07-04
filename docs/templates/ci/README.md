# CI テンプレート

各リポジトリの `.github/workflows/` にコピーして使う (2026-07 の Claude Code 監査で作成)。

| ファイル | コピー先 | 前提 |
|---|---|---|
| go-test.yml | gatehook, hb, cc-devcontainer 等の Go リポジトリ | なし |
| python-test.yml | acctf | uv。テスト未整備のうちは ruff のみ有効化 |
| claude-code-review.yml | acctf / money-analyzer / gatehook 等 | リポジトリ secrets に `ANTHROPIC_API_KEY` を登録 |

Renovate はアカウント単位で GitHub App を有効化する
(https://github.com/apps/renovate)。dotfiles には renovate.json 設定済み。
