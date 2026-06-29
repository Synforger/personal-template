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

## `task install:overlay NAME=<lang>` — 特定言語 overlay を install

```bash
task install:overlay NAME=rust TARGET=REDACTED_PATH
```

中身:
- `_overlays/<lang>/` 配下を target に rsync (= `_README.md` 除く)
- 衝突は `*.tmpl.orig` backup

**手動 follow-up が必要** (= 自動化困難な理由 = target の既存 file 構造に応じて編集が必要):
1. `.tooling/bump-targets.yaml` に overlay の bump-targets snippet を追記 (= `_overlays/<lang>/_README.md` § "bump-targets 追加" 参照)
2. `Taskfile.yml` の `includes:` に `Taskfile.<lang>.yml` への entry 追加
3. `.tooling/versions.yaml` に overlay の toolchain entry 追加

これらを忘れると新 overlay の task が呼べない / `task lint:versions` で検知されない。

## 推奨運用

- 既存 repo に**機構全部 1 発持込**したい時 → `task install:core` で base 機構入れる → 必要な言語だけ `task install:overlay` を順次
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
