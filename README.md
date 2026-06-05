# personal-template

> 個人開発リポジトリ用の **ローカル完結テスト機構付きテンプレート**。
> `task` 一発で lint / test / build / anonymity check が走り、
> GitHub Actions に課金しなくても品質ガードが手元で完結する。

## 何のためのテンプレか

AI assisted coding (= バイブコーディング) を多用する個人公開リポで、
**「気付かないうちにおかしなコードが入る / 個人名が漏れる」 を機械で止める**
ことを目的とする。 ローカルで `task lint` `task test:unit` を走らせれば、
構文ミス・未定義変数・スタイル乱れ・匿名性漏れの 4 種を一発で検出できる。

CI (GitHub Actions) は **匿名性チェック 1 本だけ** デフォルト有効、
他は workflow_dispatch + `if: false` ガードで「ジョブ本体は残置、 自動発火しない」
という安全側に倒した設計。 派生プロジェクトで必要になったら enable して使う。

## 何が入っているか

| 機能 | コマンド | 中身 |
|---|---|---|
| 統一エントリ | `task --list` | go-task/cli が全 task を提示。 何を叩けばいいか忘れない |
| 初期セットアップ | `task setup` | OS 別スクリプトで `.venv` 構築・hooks 設定 |
| Lint + 整形 | `task lint` | black / flake8 / anon-scan の 3 段 |
| 単体テスト | `task test:unit` | pytest tests + doctest |
| 結合テスト | `task test:integration` | pytest tests/integration |
| 実行可能 build | `task build:exe` | PyInstaller (Python 案件向け) |
| API / Web 起動 | `task run:api` / `task run:web` | FastAPI / Sphinx docs preview |
| docs 鮮度チェック | `task docs:check` | md 内のパス参照 / task 名 / ツリー図 が実態と一致するか機械検証。 統合前に 1 回走らせる (lint には入れない設計) |
| 匿名性 commit ガード | `.githooks/pre-commit` | staged ファイルだけ anon-scan、 軽量 |
| 匿名性 CI ガード | `.github/workflows/anon-check.yml` | push / PR で全文 anon-scan、 漏れたら CI 赤 |
| main/develop 直 commit ガード | `.githooks/pre-commit` 内 | 個人リポでは無効化想定だが、 hook を有効にすれば機能する |

匿名性パターンの**真値は `.tooling/local-ci/anon-words.txt`**（禁止ワードを
1 行 1 PCRE 片で列挙、`#` 始まりの行と空行は無視）。`.tooling/local-ci/anon-scan.sh`
がこれを読んで `|` 連結した (?i) PCRE を組み、pre-commit hook（staged のみ）と
`.github/workflows/anon-check.yml`（push / PR で全文）の**両方が同じ scanner を呼ぶ**。
ワードを足すときは `anon-words.txt` 1 ファイルだけ直せばよく、二重実装の
semantics drift が構造的に起きない。

## 言語ごとの追加チェックの足し方

このテンプレは現状 **Python 前提** (= black / flake8 / pytest / pyinstaller)
で組まれている。 他言語で使う場合は `.tooling/os/<os>/` 配下のスクリプトを
言語ツールに差し替える:

| 言語 | lint / format | test |
|---|---|---|
| Python | black + flake8 | pytest |
| JavaScript / TypeScript | prettier + eslint | vitest / jest |
| Rust | cargo fmt + cargo clippy | cargo test |
| Go | gofmt + go vet | go test |

`.tooling/os/macos/lint.sh` の構造 (= `task` の OS dispatch + 中身は自由) を
そのまま流用すればどの言語でも同じ `task lint` 体験になる。

## 使い方 (派生プロジェクト初期化)

```bash
# 1. このテンプレを丸ごとコピー
cp -R ~/repos/personal-template ~/repos/<new-project>
chmod -R u+w ~/repos/<new-project>
cd ~/repos/<new-project>

# 2. パッケージ名・GitHub URL・Python バージョン等を対話設定
pip install -r setup-requirements.txt
python personalize.py

# 3. 開発依存インストール
pip install -e ".[dev]"

# 4. Git hooks 設定
git config --local core.hooksPath .githooks
chmod -R +x .githooks/

# 5. 初回コミット + push
git init
git add -A
git commit -m "initial: project setup from personal-template"
gh repo create synforger/<new-project> --public --source=. --push
```

## ディレクトリ構成 (要点)

```
personal-template/
├── README.md                 # このファイル
├── Taskfile.yml              # 統一エントリ、 task --list で全部見える
├── LICENSE                   # Apache-2.0
├── pyproject.toml            # Python パッケージ定義 (派生時に書き換え)
├── pytest.ini / .flake8 / .coveragerc  # 各ツール設定
├── pyinstaller.spec          # exe ビルド (Python 案件向け)
├── personalize.py            # パッケージ名・GitHub URL 等の対話 rename
├── src/my_package/           # Python ソース スカフォールド
├── tests/                    # テスト
├── docs/source/              # Sphinx docs 骨格
├── scripts/
│   └── setup-branch-protection.sh   # main 保護を gh CLI で設定
├── .githooks/
│   └── pre-commit            # main/develop ガード + anon-scan
├── .tooling/
│   ├── local-ci/
│   │   └── anon-scan.sh      # perl PCRE スキャナ
│   └── os/{macos,ubuntu,windows}/   # OS 別 setup/update/run/lint/test/build
└── .github/
    └── workflows/
        ├── README.md           # workflows policy
        └── anon-check.yml      # 匿名性 CI ガード (enabled)
```

## 注意

- このテンプレ自体は **読み取り専用** (`chmod -R a-w`) で運用。 派生時に
  `chmod -R u+w <new-project>` で解放してから編集する
- 派生プロジェクトの言語が Python でない場合、 `pyproject.toml` /
  `pytest.ini` 等を削除して言語固有設定に置き換える
- `anon-check.yml` の PCRE パターンは個人公開リポ用に強化済。 派生で別所属
  が増えたら同じパターンに追記する
