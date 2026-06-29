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

現 revision は **Python overlay 強制**。 他言語 (= node / rust / swift / kotlin / csharp) overlay は今後の PR で追加予定。 multiselect 化されるまでは Python 前提のリポでのみ派生してください。

## back-port (= 既存 repo へのテンプレ機構持ち込み)

`task install:core` で既存 repo にこのテンプレの `_core/` 機構を後追い install できる予定 (= 今後の PR で実装)。
