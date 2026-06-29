# `_overlays/python/` — Python overlay

`task init` で **Python overlay を選んだ場合** root に昇格する中身。 library 型 default で `src/my_package/` 構造を採用。

## 構成

```
_overlays/python/
├── _README.md             # このファイル
├── pyproject.toml         # build-system + project metadata + dev/api/cli/pyinstaller extras
├── pytest.ini             # pytest 設定
├── pyinstaller.spec       # exe ビルド設定
├── .flake8                # flake8 設定
├── .coveragerc            # coverage.py 設定
├── .dockerignore          # Docker build context 除外
├── src/my_package/        # Python source 雛形 (= __init__ + api/ + cli/ + utils/ + version)
├── tests/                 # pytest 骨格 (= __init__ + conftest)
├── Taskfile.python.yml    # py: namespace task 定義 (= py:setup / py:lint / py:test:unit 等)
└── .tooling/os/<os>/python/   # OS 別スクリプト (= setup / update / lint / test-* / build-exe / run-api)
```

## task 一覧 (= `py:` namespace)

| task | 中身 |
|---|---|
| `py:setup` | `.venv` 構築 + dev deps install + git hooks 配備 |
| `py:update` | dev deps update |
| `py:lint` | black + flake8 + anon-scan |
| `py:test:unit` | pytest tests (= unit) |
| `py:test:integration` | pytest tests/integration |
| `py:build:exe` | PyInstaller で standalone exe build |
| `py:run:api` | FastAPI server 起動 |

## 言語非依存 wrapper との関係

`_core/Taskfile.yml` の言語非依存 wrapper (= `task setup` / `task lint` / `task test:unit` 等) は現 revision では `py:*` に直接委譲。 multi-language 派生対応は今後の PR で追加 (= 派生時 init が active overlay 群に fan-out する形に拡張)。

## 依存

- Python `>=3.10` (= pyproject.toml `requires-python` 参照)
- 全 dev deps は `pip install -e ".[dev]"` で一括 install

## Sphinx 廃止

旧 revision は Sphinx を dev extras に含めていたが、 個人 OSS scope では overkill のため廃止。 docs は `_core/docs/` の md ベース 2 層構造のみ。 必要なら派生で MkDocs / Docusaurus 等を手動追加可能。
