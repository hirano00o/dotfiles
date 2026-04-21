---
name: lang-go
description: Go 言語での TDD 実装手順。テスト実行・フォーマット・リンタ・依存管理の具体コマンド、およびテーブル駆動テスト規約。
---

# Go 実装ガイド

## テスト

```bash
go test ./...                 # 全パッケージのテスト
go test -run TestName ./pkg   # 特定テストのみ
go test -race ./...           # データ競合検出
go test -cover ./...          # カバレッジ
go test -v ./pkg              # 詳細出力
```

- **テーブル駆動テスト**を第一選択とする
- サブテスト名は `t.Run(tc.name, ...)` で付与
- 並行実行可能なテストは `t.Parallel()` を明示
- テストファイルは `*_test.go`、同一パッケージ配置が基本

例:
```go
func TestAdd(t *testing.T) {
    tests := []struct {
        name string
        a, b int
        want int
    }{
        {"zero", 0, 0, 0},
        {"positive", 2, 3, 5},
    }
    for _, tc := range tests {
        t.Run(tc.name, func(t *testing.T) {
            if got := Add(tc.a, tc.b); got != tc.want {
                t.Errorf("Add(%d, %d) = %d, want %d", tc.a, tc.b, got, tc.want)
            }
        })
    }
}
```

## フォーマット

```bash
gofmt -w .        # 保存時整形
goimports -w .    # import も含めて整形 (推奨)
```

## リンタ / 静的解析

```bash
go vet ./...                    # 標準の静的解析
golangci-lint run ./...         # 包括的リンタ (推奨)
golangci-lint run --fix ./...   # 自動修正可能なものを適用
```

## 依存管理

```bash
go mod tidy              # 不要な依存の削除 + 整理
go get example.com/pkg   # 依存追加
go mod download          # 依存ダウンロードのみ
```

## 規約

- 公開シンボル (大文字始まり) には必ず doc コメント (`// FuncName ...` で始める)
- `error` は最後の戻り値、ラップは `fmt.Errorf("context: %w", err)`
- `context.Context` は第一引数
- `panic` はライブラリコードで使わない (プログラマのバグ検出のみ)
- interface は利用側 (consumer) で定義する
- 外部パッケージのインターフェースをテスト用モックに差し替える場合は境界のみに限定

## TDD サイクル内での典型実行順

1. Red: テストを書く → `go test ./pkg` で失敗確認
2. Green: 実装 → `go test ./pkg` で緑化
3. Refactor: コード整理 → `go test ./...` で全体緑維持
4. Lint: `go vet ./...` → `golangci-lint run ./...`
5. Format: `goimports -w .`
