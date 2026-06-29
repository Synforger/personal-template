# `_overlays/rust/` — Rust overlay

`task init` で **rust overlay を選んだ場合** root に昇格する中身。 library 型 (= `src/lib.rs`)、 cargo が package manager。

## 構成

```
_overlays/rust/
├── _README.md              # このファイル
├── Cargo.toml              # package metadata + rust-version pin
├── src/lib.rs              # library entry
├── tests/integration_test.rs   # integration test 雛形
└── Taskfile.rust.yml       # rust: namespace task
```

## task 一覧 (= `rust:` namespace)

| task | 中身 |
|---|---|
| `rust:setup` | `cargo fetch` |
| `rust:update` | `cargo update` |
| `rust:lint` | `cargo fmt --check` + `cargo clippy --all-targets -- -D warnings` |
| `rust:test:unit` | `cargo test --lib` |
| `rust:test:integration` | `cargo test --tests` |
| `rust:build` | `cargo build --release` |
| `rust:run` | `cargo run` (= binary overlay 時のみ意味あり、 library overlay では no-op) |

## 依存

- Rust `>=1.75` (= `versions.yaml` 参照、 2024 標準)
- cargo (= rustup install で同梱)

## bump-targets 追加 (= init で append)

```yaml
- file: Cargo.toml
  replacements:
    - search: 'version = "{OLD}"'
      replace: 'version = "{NEW}"'
```
