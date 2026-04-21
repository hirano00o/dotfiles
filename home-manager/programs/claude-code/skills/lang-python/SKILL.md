---
name: lang-python
description: Python の TDD 実装手順。pytest、ruff (lint + format)、mypy / pyright、uv による依存管理の具体コマンド。
---

# Python 実装ガイド

## 環境判定

- `pyproject.toml` の `[tool.ruff]`, `[tool.pytest.ini_options]`, `[tool.mypy]` を確認
- `uv.lock` があれば uv、`poetry.lock` があれば Poetry、`requirements.txt` のみなら pip
- 仮想環境の場所: `.venv/` が一般的

## テスト

```bash
pytest                        # 全テスト
pytest -q                     # 簡潔出力 (推奨)
pytest path/to/test_file.py   # 特定ファイル
pytest -k "pattern"           # 名前パターン
pytest -x                     # 初回失敗で停止
pytest --lf                   # 前回失敗分のみ
pytest -v                     # 詳細
```

- テストファイル命名: `test_*.py` or `*_test.py`
- テスト関数: `def test_*():`
- フィクスチャは `conftest.py` に集約
- パラメータ化: `@pytest.mark.parametrize("a,b,want", [...])`

例:
```python
import pytest

@pytest.mark.parametrize(
    "a,b,want",
    [
        (0, 0, 0),
        (2, 3, 5),
    ],
)
def test_add(a: int, b: int, want: int) -> None:
    assert add(a, b) == want
```

## Lint / Format

**ruff (推奨)**:
```bash
ruff check .               # lint 実行
ruff check --fix .         # 自動修正
ruff format .              # フォーマット
```

## 型チェック

```bash
mypy .                     # プロジェクト全体
mypy path/to/module.py     # 特定モジュール
pyright                    # 代替: 高速で厳格
```

- 公開関数には型注釈を必須
- `from __future__ import annotations` で前方参照をサポート (Python 3.7+)
- `Optional[X]` より `X | None` (Python 3.10+)

## 依存管理

```bash
# uv (推奨)
uv sync                    # ロック通りインストール
uv add <pkg>               # 依存追加
uv add --dev <pkg>         # 開発依存
uv run <cmd>               # 仮想環境内で実行
uv lock                    # ロックファイル再生成

# pip
pip install -e .           # editable install
pip install -r requirements.txt
```

## 規約

- Docstring は Google / NumPy / reST スタイルのいずれかに統一 (プロジェクト既存方針に従う)
- 公開 API の Docstring は必須
- 例外は具体クラスを捕捉 (`except Exception:` は原則避ける)
- `pathlib.Path` を優先し、文字列パス操作は避ける
- I/O バウンド処理は `async` / `asyncio` を検討

## TDD サイクル内での典型実行順

1. Red: テスト作成 → `pytest -q <file>` で失敗確認
2. Green: 実装 → `pytest -q <file>` で緑化
3. Refactor: → `pytest -q` で全体緑維持
4. Type: `mypy .` or `pyright`
5. Lint: `ruff check --fix .`
6. Format: `ruff format .`
