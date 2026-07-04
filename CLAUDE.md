# dotfiles

## コマンド

```sh
# 検証ビルド (適用なし)
darwin-rebuild build --flake .#privateDarwin
# 評価のみ (高速な構文/型チェック)
nix eval .#darwinConfigurations.privateDarwin.system.drvPath
# 適用
sudo darwin-rebuild switch --flake .#privateDarwin
```

workDarwin は `users/work/flake.nix` のプレースホルダ未設定だと評価が throw する
(README の手順参照)。private マシンでは privateDarwin のみ検証すればよい。

## 構成の要点

- Claude Code 関連 (settings / permissions / hooks / MCP / skills / agents) はすべて
  `home-manager/programs/claude-code/default.nix` が起点
- `~/.claude/settings.json` 等は nix store への symlink。直接編集せず、
  このリポジトリを変更して switch で反映する
- work / private の差分は `home-manager/programs/claude-code/work.nix` と
  `hosts/` の各 default.nix で `mkForce` 上書き
- secrets は sops-nix (`secrets/*.enc.yaml`)。編集は `sops` CLI 経由のみ

## 固有ルール

- 新しいスキル / エージェント / スクリプトを追加したら必ず `default.nix` に登録する
  (登録漏れはデプロイされず、リポジトリ内でデッドコードになる)
- nix ファイルは新規ファイルを untracked のまま評価しない (`git add` してから
  `nix eval`。nix は git 管理外ファイルを見ない)
- drawio スキルの更新は fetchurl の commit hash と sha256 を両方更新する
