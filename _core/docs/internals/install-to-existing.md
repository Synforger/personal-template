# 既存 repo へのテンプレ機構持ち込み (= back-port)

`personal-template` から派生する新規 repo だけでなく、 既存の個人 repo にもこのテンプレの機構を**後追い** install できる。 2 つの script があり、 用途で使い分ける。

## `task install:core` — 言語非依存機構を一式 install

```bash
cd REDACTED_PATH
task install:core TARGET=REDACTED_PATH
```

中身:
- `_core/` 配下 (= `.tooling/`, `.githooks/`, `.github/workflows/`, `scripts/`, `docs/`, `Taskfile.yml`, `SECURITY.md`, `ROADMAP.md`, `THIRD_PARTY_NOTICES.md`, `personalize.py` 等) を target repo に rsync
- 既存 file との衝突は `<name>.tmpl.orig` という backup を残して上書き (= 手動 merge 用)
- `README.md` / `LICENSE` / `.gitignore` は target が持ってる前提で skip
- `DRY_RUN=1` で実走前 plan 表示

```bash
# plan 確認
DRY_RUN=1 task install:core TARGET=REDACTED_PATH

# 衝突確認
find REDACTED_PATH -name '*.tmpl.orig'

# 1 件ずつ手動 merge
diff -u <orig> <orig>.tmpl.orig    # 元 + 新 の差分
```

## install:core 後の手動 follow-up

target の既存 file 構造に応じて編集が必要なため自動化していない:
1. `.tooling/bump-targets.yaml` に version file の entry を追記
2. Taskfile の stack stub (setup / lint / test / build / run) を自分の stack で埋める
3. `.tooling/versions.yaml` に使う toolchain の floor entry 追加
4. **LICENSE を置く** (= `install:core` は LICENSE を skip するので、 持っていない repo は持っていないまま残り、 `task publish:check` が落ちる)

これらを忘れると `task lint:versions` / release driver / `publish:check` が正しく機能しない。

### 埋め方の実例 (= python + venv の repo)

`echo` を残さず、 その repo が実際に叩くコマンドを書く。 動詞名は変えない (= 派生がどれも
同じ動詞に答えることが、 この Taskfile を共有している理由)。

```yaml
  setup:
    desc: Create the virtualenv and install the package
    cmds:
      - python3 -m venv .venv
      - .venv/bin/pip install -q -e .

  lint:
    desc: Compile every source file (= linter を宣言していない repo の syntax gate)
    cmds:
      - .venv/bin/python -m compileall -q src

  test:unit:
    cmds: [.venv/bin/python -m unittest discover -s tests -v]

  build:
    cmds: [.venv/bin/python -m pip wheel -q --no-deps -w dist .]
```

version の在処と toolchain の床は、 その repo の実物に合わせる:

```yaml
# .tooling/bump-targets.yaml
current_version: "0.1.0"
targets:
  - file: pyproject.toml
    replacements:
      - search: 'version = "{OLD}"'
        replace: 'version = "{NEW}"'

# .tooling/versions.yaml — 使わない言語の entry は消す
python: ">=3.11"     # pyproject の requires-python と一致させる (= lint:versions が突き合わせる)
```

### 持ち込み直後に出やすい 3 件

- **`task doctor` が repo-local の語リストの drift を言う** — マシン側に master が在る構成では
  `.tooling/local-ci/anon-words.txt` を消して一本化する (= 2 か所に持つと、 どちらが真値か分からなくなる)
- **`task docs:check` が repo 名を path と読む** — `` `owner/repo` `` のようにバッククォートで囲むと
  path 参照として扱われる。 囲まずに書く
- **README の「次は〜」が完了済みの記述で残る** — 持ち込みと同じ PR で現状に直す
- **`task version:bump` が `error: PyYAML not installed` で落ちる** — `version-bump.sh` は
  PyYAML を使うが、 `setup-requirements.txt` にも `doctor` にも宣言が無い。 入れるまで release
  driver は動かない (= 雛形自身の bats も同じ理由で赤くなる)

## 推奨運用

- 既存 repo に**機構全部 1 発持込**したい時 → `task install:core`
- **1 機構だけ持込**したい時 (= 例: docs-check のみ) → `install:core` + 不要 file 削除、 or 該当 file だけ手動 cp
- 既存 repo の Taskfile / pre-commit hook が違う設計の場合 = `.tmpl.orig` を見て手動マージ、 衝突大きいなら段階的に持ち込む方が現実的

## back-port 後の verify

target repo で:

```bash
cd REDACTED_PATH
task doctor        # toolchain floor 確認
task lint:versions # 下流 config drift 検知
task docs:check    # docs 鮮度
task audit         # security
```

緑なら持ち込み成功。 fail なら `.tmpl.orig` と diff して手動調整。
