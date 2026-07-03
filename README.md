# personal-template

> 個人公開リポジトリ用の **言語非依存テンプレート**。
> `_core/` (= 全派生共通) + `_overlays/<lang>/` (= 言語別 opt-in) の 2 層構造で、
> `task init` 1 発で派生プロジェクトの足場が完成する。

## このテンプレが提供するもの

| カテゴリ | 中身 |
|---|---|
| **ローカル CI 完結** | `task lint` / `task test:unit` / `task docs:check` で品質ガードが手元で全部走る (= GitHub Actions 課金ゼロ運用) |
| **匿名性ガード** | dispatcher hooks (= pre-commit / commit-msg / pre-push) + `task audit:deep` で個人名 / 業務識別子の混入を機械検出 (= 語リストは非公開、 CI には置かない設計) |
| **secret ガード** | pre-commit hook に gitleaks 同梱、 API key / password / private key の流入を機械検出 |
| **docs 鮮度ガード** | md 内の path 参照 / `task` 名 / tree 図 / git conflict marker (4 軸) が実態と一致するか機械検証 |
| **toolchain 真値一元化** | `.tooling/versions.yaml` 1 file で host floor を集約、 `task doctor` で MISSING / TOO OLD / OK を診断、 `task lint:versions` で下流 config drift を検知 |
| **集約 security audit** | `task audit` で anon-scan + gitleaks 全履歴 + pip-audit + npm audit + cargo audit を 1 発実行、 不在 tool は skip |
| **per-layer clean** | `task clean LAYER=<layer>` で言語別 build artefact + cache を選択削除 (= python/node/rust/swift/kotlin/cs/docs/all) |
| **release driver** | `task release:cut LEVEL=patch\|minor\|major` で version bump + commit + tag + push を 1 発、 DRY_RUN=1 で plan 確認 |
| **公開 OSS 必須要件** | `SECURITY.md` / `ROADMAP.md` / `THIRD_PARTY_NOTICES.md` template 同梱、 後者は `task gen-notices` で自動生成 |
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
├── Taskfile.yml                  # init / install:core / install:overlay (= 派生時に _core/Taskfile.yml で上書き)
├── _core/                        # 言語非依存の共通機構 (全派生で root に昇格)
│   ├── _README.md
│   ├── .gitignore / .vscode/
│   ├── Taskfile.yml              # core task 定義 (= 派生後 root Taskfile.yml になる)
│   ├── .githooks/pre-commit      # repo-local hook (= dispatcher から委譲される側)
│   ├── git-hooks/                # global hooks dispatcher (= pre-commit / commit-msg / pre-push
│   │   │                         #   + doctor.sh + install.sh、 マシン全体の関所)
│   │   └── lib/dispatcher-common.sh
│   ├── .github/
│   │   ├── ISSUE_TEMPLATE/
│   │   └── workflows/version-bump.yml
│   ├── .tooling/local-ci/        # anon-scan / anon-fix / anon-audit-deep / anon-sync-truth /
│   │                             #   docs-check / doctor / audit / clean / lint-versions /
│   │                             #   version-bump / release-cut / setup-lib
│   ├── docs/                     # 利用者/contributor 2 層構造 placeholder
│   ├── scripts/                  # init.py / install-core.sh / install-overlay.sh /
│   │                             #   post-init-github-settings.sh / setup-branch-protection.sh /
│   │                             #   gen-third-party-notices.py
│   ├── personalize.py
│   └── setup-requirements.txt
└── _overlays/                    # 言語別 opt-in 機構 (選んだ overlay だけ root に昇格)
    ├── _README.md
    └── <lang>/                   # python / node / rust / swift / kotlin / csharp の 6 overlay
        ├── _README.md
        ├── (言語別 config: pyproject.toml / package.json / Cargo.toml / ...)
        ├── src/ + tests/
        ├── Taskfile.<lang>.yml
        └── .tooling/os/<os>/<lang>/
```

## 言語選択 (= 6 overlay すべて active)

`task init` で対話 multiselect、 または `OVERLAYS=` で非対話指定:

| overlay | prefix | 内容 |
|---|---|---|
| python | `py:`     | pyproject + pytest + pyinstaller |
| node   | `node:`   | package.json + tsconfig + vitest + eslint |
| rust   | `rust:`   | Cargo.toml + lib.rs + cargo test/fmt/clippy |
| swift  | `swift:`  | SwiftPM library |
| kotlin | `kotlin:` | Gradle Kotlin library + JUnit 5 |
| csharp | `cs:`     | .NET 8 class library + xUnit |

`task init:github` で template 化で引き継がれない GitHub settings (= secret scanning / PVR / merge config / branch protection) を gh CLI 経由で 1 発復元。

既存 repo への back-port は `task install:core TARGET=<path>` で `_core/` 機構を、 `task install:overlay NAME=<lang> TARGET=<path>` で特定言語 overlay を、 後追い install。 衝突は `*.tmpl.orig` backup で保護、 詳細は [`_core/docs/internals/install-to-existing.md`](_core/docs/internals/install-to-existing.md) 参照。

詳細は [`_overlays/_README.md`](_overlays/_README.md) 参照。

## 設計思想

- **構造美の徹底** — overlay 間で file 配置 / task 名 / OS スクリプト構造を完全対称化
- **機能保存** — 既存 personal-template の機構は basically 全部温存、 削除は真に不要なもの (= Sphinx) のみ
- **追加 cost 最小** — 1 overlay = self-contained dir、 言語追加は dir 配備 + versions.yaml 1 行 + Taskfile.<lang>.yml 1 file
- **言語非依存 core** — anon / docs-check / pre-commit / GitHub workflow / branch protection は全部 `_core/` で共通化

## License

Apache-2.0 (= [`LICENSE`](LICENSE))
