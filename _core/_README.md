# `_core/` — 言語非依存の共通機構

派生プロジェクトで**言語を問わず全部入る**機構の置き場。 `task init` 実行時に中身が repo root に昇格し、 `_core/` 自体は削除される。

## ここに入っているもの

- **`Taskfile.yml`** — core task 群 (= setup / lint / test / build / docs:check 等の言語非依存 wrapper)
- **`.githooks/pre-commit`** — main/develop 直 commit guard + anon-scan
- **`.github/`** — ISSUE_TEMPLATE 3 種 + workflows (= anon-check / version-bump)
- **`.tooling/local-ci/`** — anon-scan.sh / docs-check.sh / 関連 ignore リスト
- **`scripts/`** — setup-branch-protection.sh / init.sh
- **`docs/`** — 利用者/contributor 2 層構造の placeholder
- **`personalize.py`** — パッケージ名 / GitHub URL 等の対話 rename
- **`setup-requirements.txt`** — personalize.py の依存 (click + rich)
- **`LICENSE`** — Apache-2.0
- **`.gitignore`** — 共通 ignore (= anon-words.txt + 一般的 build artifact)
- **`.vscode/`** — editor 設定

## ここに置く判断

「派生 repo の言語が何であっても入る」 なら `_core/`。 「特定言語でしか意味がない」 なら `_overlays/<lang>/`。

例:
- pre-commit hook → core (= 言語によらず必要)
- anon-scan → core (= 言語によらず必要)
- pyproject.toml → python overlay (= Python でしか使わない)
- Cargo.toml → rust overlay (= Rust でしか使わない)
