# `_overlays/` — 言語別の opt-in 機構

派生プロジェクトの言語ごとに**選択的に root に展開する**機構置き場。 `task init` で選んだ言語の overlay 中身が repo root に昇格し、 選ばなかった overlay と `_overlays/` 自体は削除される。

## 現状の overlay 構成

| overlay | 状態 | 中身 |
|---|---|---|
| [`python/`](python/) | active | pyproject.toml / pytest / flake8 / pyinstaller / src/my_package / Sphinx 非依存 |
| `node/` | 未配備 | 今後の PR で追加 (= package.json / eslint / vite 等) |
| `rust/` | 未配備 | 今後の PR で追加 (= Cargo.toml / src/lib.rs 等) |
| `swift/` | 未配備 | 今後の PR で追加 (= SwiftPM Package.swift 等) |
| `kotlin/` | 未配備 | 今後の PR で追加 (= Gradle build.gradle.kts 等) |
| `csharp/` | 未配備 | 今後の PR で追加 (= .NET class library) |

## overlay の設計原則

- **library 型 default** = 全 overlay で `src/<lib-name>/` 統一 (= app/binary 系派生は init 後の手動拡張)
- **Taskfile.<lang>.yml** = 言語別 task 定義、 task 名は `<lang_prefix>:setup` / `<lang_prefix>:lint` / `<lang_prefix>:test:unit` / `<lang_prefix>:build` で揃える (= 構造美)
- **OS スクリプト** = `.tooling/os/<os>/<lang>/{setup,lint,test-*,build-*}.sh` の sub-dir 方式で言語別分離
- **versions.yaml entry** = 言語ごとに 1 行、 alphabet 順
- **追加 cost 最小化** = 1 overlay = self-contained dir、 中央 logic に追加なし

## overlay の prefix 命名

| overlay | task prefix |
|---|---|
| python | `py:` |
| node | `node:` |
| rust | `rust:` |
| swift | `swift:` |
| kotlin | `kotlin:` |
| csharp | `cs:` |
