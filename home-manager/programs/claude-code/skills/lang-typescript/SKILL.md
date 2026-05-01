---
name: lang-typescript
description: TypeScript / JavaScript の TDD 実装手順。Vitest / Jest / bun test、Biome / ESLint + Prettier、tsc、パッケージマネージャ (pnpm / npm / bun) の具体コマンド。
---

# TypeScript 実装ガイド

## 環境判定

プロジェクト構成を確認してテストランナ・ツールチェインを決定する:

- `package.json` の `scripts`, `devDependencies` を確認
- `biome.json` / `biome.jsonc` があれば Biome、`.eslintrc*` / `eslint.config.*` があれば ESLint + Prettier
- `vitest.config.*` があれば Vitest、`jest.config.*` があれば Jest、`bunfig.toml` + テスト規約があれば bun test
- `pnpm-lock.yaml` / `package-lock.json` / `bun.lockb` でパッケージマネージャを判定

## テスト

```bash
# Vitest
vitest run                       # 1 回実行
vitest run path/to/file.test.ts  # 特定ファイル
vitest run -t "pattern"          # 名前パターン
vitest                           # watch モード (CI では使わない)

# Jest
jest
jest path/to/file.test.ts
jest -t "pattern"

# bun test
bun test
bun test path/to/file.test.ts
```

- テストファイル命名: `*.test.ts` / `*.spec.ts`
- `describe` / `it` のネストは 2 階層以内
- 振る舞いベースで書く (実装詳細 = 内部メソッド呼び出し回数などをモックしない)

## フォーマット / リンタ

**Biome (推奨)**:
```bash
biome check --write .      # lint + format を一括適用
biome check .              # 確認のみ
biome format --write .     # format のみ
```

**ESLint + Prettier**:
```bash
eslint . --fix
prettier -w .
```

## 型チェック

```bash
tsc --noEmit              # 型のみ検証 (ビルド物を出さない)
tsc --noEmit --watch      # 開発時の監視 (CI では使わない)
```

## 依存管理

```bash
# pnpm
pnpm install              # ロックファイル尊重
pnpm add <pkg>
pnpm add -D <pkg>         # devDependencies

# npm
npm ci                    # ロックファイル尊重 (推奨)
npm install <pkg>

# bun
bun install
bun add <pkg>
bun add -d <pkg>
```

## 規約

- `any` の使用は明確な理由がある場合のみ (`unknown` で代替できないか検討)
- Non-null assertion (`!`) は境界値 (外部データ) では使わない。型ガードで絞り込む
- `Result<T, E>` パターンか例外かはプロジェクト既存の方針に従う
- JSDoc は公開 API に付ける (`/** ... */`)

## TDD サイクル内での典型実行順

1. Red: テスト作成 → `vitest run <file>` で失敗確認
2. Green: 実装 → `vitest run <file>` で緑化
3. Refactor: → `vitest run` で全体緑維持
4. Type: `tsc --noEmit`
5. Lint/Format: `biome check --write .`
