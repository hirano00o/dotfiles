---
name: lang-rust
description: Rust の TDD 実装手順。cargo test / nextest、cargo fmt、cargo clippy、cargo check / build、cargo add の具体コマンド。
---

# Rust 実装ガイド

## 環境判定

- `Cargo.toml` の `[workspace]` 有無でワークスペース構成を判定
- `rust-toolchain.toml` の channel を確認 (stable / nightly)
- nextest 利用有無: `.config/nextest.toml` or `cargo-nextest` の dev-dependency

## テスト

```bash
cargo test                          # 全テスト
cargo test --package <pkg>          # 特定パッケージ
cargo test <name>                   # 名前に含むテスト
cargo test --test <integration>     # 統合テストファイル
cargo test -- --nocapture           # 標準出力を表示

# nextest (推奨、高速)
cargo nextest run
cargo nextest run -p <pkg>
cargo nextest run <name>
```

- **単体テスト**: 実装ファイル内の `#[cfg(test)] mod tests { ... }` に配置
- **統合テスト**: `tests/` ディレクトリ (クレートの public API 経由でテスト)
- **doc テスト**: doc コメント内のコード例が自動実行される

例:
```rust
pub fn add(a: i32, b: i32) -> i32 {
    a + b
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn zero() {
        assert_eq!(add(0, 0), 0);
    }

    #[test]
    fn positive() {
        assert_eq!(add(2, 3), 5);
    }
}
```

## フォーマット

```bash
cargo fmt                    # プロジェクト全体
cargo fmt --check            # 確認のみ (CI 用)
```

## リンタ

```bash
cargo clippy --all-targets --all-features -- -D warnings   # 警告をエラー扱い (推奨)
cargo clippy --fix --allow-dirty --allow-staged            # 自動修正
```

## ビルド / 型チェック

```bash
cargo check --all-targets    # 型チェックのみ (高速)
cargo build                  # debug ビルド
cargo build --release        # release ビルド
```

## 依存管理

```bash
cargo add <crate>                        # 依存追加
cargo add <crate> --features <feat>      # feature 指定
cargo add <crate> --dev                  # dev-dependencies
cargo remove <crate>
cargo update                             # ロックファイル更新 (慎重に)
cargo update -p <crate>                  # 特定クレートのみ
```

## 規約

- 公開アイテム (pub) には `///` doc コメントを必須
- `unwrap()` / `expect()` はテストコードと "絶対に失敗しない" と明示できる場合のみ
- エラー型は `thiserror` / `anyhow` をプロジェクト既存方針に従って使い分け
- `unsafe` は使わない。必要な場合は安全性不変条件を SAFETY コメントで必ず書く
- Lifetime 注釈は必要最小限。Rust コンパイラの推論に任せる
- `Clone` / `Copy` は意味的に妥当な場合のみ derive

## TDD サイクル内での典型実行順

1. Red: テスト作成 → `cargo test <name>` で失敗確認
2. Green: 実装 → `cargo test <name>` で緑化
3. Refactor: → `cargo test` で全体緑維持
4. Check: `cargo check --all-targets`
5. Lint: `cargo clippy --all-targets --all-features -- -D warnings`
6. Format: `cargo fmt`
