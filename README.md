# personal-template

> 個人公開リポジトリ用の **言語非依存テンプレート**。
> `_core/` (= 全派生共通) + `_overlays/<lang>/` (= 言語別 opt-in) の 2 層構造で、
> `task init` 1 発で派生プロジェクトの足場が完成する。

## このテンプレが提供するもの

| カテゴリ | 中身 |
|---|---|
| **ローカル CI 完結** | `task lint` / `task test:unit` / `task docs:check` で品質ガードが手元で全部走る (= GitHub Actions 課金ゼロ運用) |
| **匿名性ガード** | pre-commit hook + CI workflow で個人名 / 業務識別子の混入を機械検出 |
| **docs 鮮度ガード** | md 内の path 参照 / `task` 名 / tree 図 が実態と一致するか機械検証 |
| **toolchain 真値一元化** | `.tooling/versions.yaml` 1 file で host floor を集約、 `task doctor` で MISSING / TOO OLD / OK を診断、 `task lint:versions` で下流 config drift を検知 |
| **branch protection** | gh CLI で main 保護を 1 発設定 |
| **対話 personalization** | パッケージ名 / GitHub URL / バージョン等の placeholder を対話的に置換 |

派生プロジェクトは上記機構が全部入った状態でスタートできる。

## 使い方 (= 派生プロジェクト初期化、 4 step)

```bash
# 1. このテンプレを「Use this template」 で新 repo 作成 → clone
gh repo create synforger/<new-project> --template synforger/personal-template --clone

# 2. テンプレ構造を root に展開 (= _core + 選んだ overlay を昇格、 残骸 dir を削除)
cd <new-project>
task init

# 3. パッケージ名 / GitHub URL / バージョン等を対話設定
pip install -r setup-requirements.txt
python personalize.py

# 4. 開発依存 install + git hooks 配備
task setup
```

派生後の構造・運用は [`_core/docs/internals/template-usage.md`](_core/docs/internals/template-usage.md) を参照 (= このファイルは `task init` で削除される)。

## 構造 (= template state)

```
personal-template/
├── README.md                     # このファイル (= template 状態の入口)
├── Taskfile.yml                  # task init のみ (= 派生時に _core/Taskfile.yml で上書き)
├── _core/                        # 言語非依存の共通機構 (全派生で root に昇格)
│   ├── _README.md
│   ├── LICENSE / .gitignore / .vscode/
│   ├── Taskfile.yml              # core task 定義 (= 派生後 root Taskfile.yml になる)
│   ├── .githooks/pre-commit
│   ├── .github/
│   │   ├── ISSUE_TEMPLATE/
│   │   └── workflows/anon-check.yml + version-bump.yml
│   ├── .tooling/local-ci/        # anon-scan.sh / docs-check.sh
│   ├── docs/                     # 利用者/contributor 2 層構造 placeholder
│   ├── scripts/init.sh + setup-branch-protection.sh
│   ├── personalize.py
│   └── setup-requirements.txt
└── _overlays/                    # 言語別 opt-in 機構 (選んだ overlay だけ root に昇格)
    ├── _README.md
    └── python/                   # 現 revision の唯一 active overlay
        ├── _README.md
        ├── pyproject.toml / pytest.ini / pyinstaller.spec / .flake8 / .coveragerc
        ├── src/my_package/
        ├── tests/
        ├── Taskfile.python.yml
        └── .tooling/os/<os>/python/
```

## 言語選択 (= 現状)

現 revision は **Python overlay 単独**。 他言語 overlay は今後の PR で追加予定:

- node / rust / swift / kotlin / csharp (= 全部 library 型 default)
- `task init` の multiselect 化 + GitHub settings 1 発復元 (= `post-init-github-settings.sh`)
- 既存 repo への back-port (= `task install:core` / `task install:overlay name=<lang>`)

詳細ロードマップは [`_overlays/_README.md`](_overlays/_README.md) 参照。

## 設計思想

- **構造美の徹底** — overlay 間で file 配置 / task 名 / OS スクリプト構造を完全対称化
- **機能保存** — 既存 personal-template の機構は basically 全部温存、 削除は真に不要なもの (= Sphinx) のみ
- **追加 cost 最小** — 1 overlay = self-contained dir、 言語追加は dir 配備 + versions.yaml 1 行 + Taskfile.<lang>.yml 1 file
- **言語非依存 core** — anon / docs-check / pre-commit / GitHub workflow / branch protection は全部 `_core/` で共通化

## License

Apache-2.0 (= [`_core/LICENSE`](_core/LICENSE))
