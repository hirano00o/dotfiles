---
name: ship
description: 作業の区切りで変更を出荷するときに使用。「コミットして」「push して PR を作って」「PR を作成して」「ここまでをコミットして」等の指示で発動。ブランチ確認 → コミット → push → PR 作成 → URL 報告までを一括で行う。
allowed-tools: Bash, Read, Grep, Glob
---

# 出荷 (commit → push → PR)

## 手順

1. **ブランチ確認**: `git branch --show-current` を確認する。main / master に居る場合は
   変更内容を表す名前で作業ブランチを作成して移る (main への直接 push は禁止)
2. **差分確認**: `git status` と `git diff --stat` で影響範囲を確認し、想定外のファイル・
   デバッグ残骸・シークレットが含まれていないことを確かめる
3. **コミット**: 意味のある単位でファイルを個別に `git add` し、**why** を説明する
   コミットメッセージを書く (`git add -A` / `git add .` は使わない)
4. **push**: `git push -u origin <branch>`
5. **PR 作成**: リポジトリに PR テンプレートがあれば従い、`gh pr create` で作成する。
   概要には変更の why / what と検証方法を書く
6. **報告**: PR の URL を報告する

## ガード

- lint / format / テストが通っていない状態でコミットしない
- コミット前にレビュー指摘が残っていないか確認する (残っていれば先に修正)
- 既に PR が存在するブランチでは新規作成せず push のみ行い、既存 PR の URL を報告する
