# personal-template の使い方 (= 派生者向け、 init 後に削除される)

このファイルは `task init` 実行時に自動削除される。 派生 repo 作成直後の人が読む想定で書く。

## 派生フロー (= 4 step)

```bash
# 1. このテンプレを「Use this template」 で新 repo 作成 → clone
gh repo create synforger/<new-project> --template synforger/personal-template --clone

# 2. テンプレ構造を root に展開 (= _core / _overlays/python を昇格、 不要 dir 削除)
cd <new-project>
task init

# 2a. (推奨) toolchain 診断 = `task doctor` で MISSING / TOO OLD / OK を確認
task doctor

# 3. パッケージ名 / GitHub URL / Python バージョン等を対話設定
pip install -r setup-requirements.txt
python personalize.py

# 4. 開発依存 install + git hooks 配備
task setup
```

## 構造 (= 派生 repo に残る分のみ)

```
<new-project>/
├── LICENSE / README.md / .gitignore
├── Taskfile.yml                 # setup / lint / test / docs:check / py:* 等
├── Taskfile.python.yml          # python 固有 task (= py: namespace)
├── pyproject.toml / pytest.ini / .flake8 / .coveragerc
├── pyinstaller.spec
├── src/my_package/              # Python source 雛形
├── tests/                       # pytest 骨格
├── docs/                        # 利用者/contributor 2 層構造
│   ├── README.md / setup/ / ops/ / reference/
│   └── internals/               # contributor 専用
├── personalize.py               # 派生時の対話 rename
├── scripts/setup-branch-protection.sh
├── .githooks/pre-commit         # main/develop guard + anon-scan
├── .tooling/
│   ├── local-ci/                # anon-scan.sh / docs-check.sh
│   └── os/<os>/python/          # OS 別の setup/lint/test/build/run スクリプト
└── .github/
    ├── ISSUE_TEMPLATE/
    └── workflows/anon-check.yml + version-bump.yml
```

## 言語選択 (= 現状)

`task init` は **6 言語 overlay の multiselect** に対応:

| key | prefix | 概要 |
|---|---|---|
| python | `py:`     | Python library + CLI (= `src/my_package/`) |
| node   | `node:`   | Node.js / TypeScript library + CLI (= `src/index.ts`) |
| rust   | `rust:`   | Rust library (= `src/lib.rs`、 binary 化は派生で `[[bin]]` 追加) |
| swift  | `swift:`  | SwiftPM library (= `Sources/MySwiftLib/`、 iOS app は Xcode template 別) |
| kotlin | `kotlin:` | Gradle Kotlin library (= `src/main/kotlin/`、 Android app は AS template 別) |
| csharp | `cs:`     | .NET class library (= `src/*.csproj`、 Unity/WPF は別 boilerplate) |

`task init` で対話的に複数選択、 または `task init OVERLAYS=python,node,rust` で非対話実行。

## GitHub settings 1 発復元

`task init:github` で template 化で引き継がれない GitHub settings (= secret scanning / PVR / merge config / branch protection) を gh CLI 経由で自動適用。 残 manual TODO (= Non-provider patterns / CodeQL UI) は script 末尾で URL 付き表示。

## back-port (= 既存 repo へのテンプレ機構持ち込み)

既存 repo に **後追い install** する手順:

```bash
cd ~/repos/synforger/personal-template

# _core 機構一式
task install:core TARGET=~/repos/synforger/my-existing-repo

# 特定言語 overlay
task install:overlay NAME=rust TARGET=~/repos/synforger/my-existing-repo
```

衝突は `<name>.tmpl.orig` backup で残し、 上書きしない (= 手動 merge 用)。 詳細は [`install-to-existing.md`](install-to-existing.md) 参照。
