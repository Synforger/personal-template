# `_overlays/swift/` — Swift overlay

`task init` で **swift overlay を選んだ場合** root に昇格する中身。 SwiftPM library 型 (= `Sources/MySwiftLib/`)、 iOS app は別 boilerplate (= Xcode template)。

## 構成

```
_overlays/swift/
├── _README.md                              # このファイル
├── Package.swift                           # SwiftPM manifest
├── Sources/MySwiftLib/MySwiftLib.swift     # library entry
├── Tests/MySwiftLibTests/MySwiftLibTests.swift  # XCTest 雛形
└── Taskfile.swift.yml                      # swift: namespace task
```

## task 一覧 (= `swift:` namespace)

| task | 中身 |
|---|---|
| `swift:setup` | `swift package resolve` |
| `swift:update` | `swift package update` |
| `swift:lint` | `swift format lint -r Sources Tests` (= `swift-format` が必要、 未 install なら skip 警告) |
| `swift:test:unit` | `swift test --filter MySwiftLibTests.Unit` (= 命名規則で振り分け、 慣習) |
| `swift:test:integration` | `swift test --filter MySwiftLibTests.Integration` |
| `swift:build` | `swift build -c release` |
| `swift:run` | `swift run` (= 実行可能 target がある場合のみ) |

## 依存

- Swift `>=5.9` (= `versions.yaml` 参照、 Xcode 15 以降)
- swift-format (= optional、 lint 時のみ。 `brew install swift-format`)

## bump-targets 追加 (= init で append)

Swift には統一 version field がないため、 typically コードに version constant を埋めて bump-targets でそこを書き換える方針 (= 派生 repo 側で設計):

```yaml
- file: Sources/MySwiftLib/MySwiftLib.swift
  replacements:
    - search: 'static let version = "{OLD}"'
      replace: 'static let version = "{NEW}"'
```
