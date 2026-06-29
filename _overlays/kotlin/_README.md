# `_overlays/kotlin/` — Kotlin overlay

`task init` で **kotlin overlay を選んだ場合** root に昇格する中身。 Gradle library 型 (= `src/main/kotlin/`)、 Android app は別 boilerplate (= Android Studio template)。

## 構成

```
_overlays/kotlin/
├── _README.md                            # このファイル
├── build.gradle.kts                      # Gradle Kotlin DSL
├── settings.gradle.kts                   # project name
├── src/main/kotlin/MyKotlinLib.kt        # library entry
├── src/test/kotlin/MyKotlinLibTest.kt    # JUnit 5 雛形
└── Taskfile.kotlin.yml                   # kotlin: namespace task
```

## task 一覧 (= `kotlin:` namespace)

| task | 中身 |
|---|---|
| `kotlin:setup` | `./gradlew dependencies --refresh-dependencies` |
| `kotlin:update` | `./gradlew dependencyUpdates` (= versions plugin 必要、 optional) |
| `kotlin:lint` | `./gradlew ktlintCheck detekt` (= 両 plugin 設定済前提) |
| `kotlin:test:unit` | `./gradlew test` |
| `kotlin:test:integration` | `./gradlew integrationTest` (= source set 分けてる前提) |
| `kotlin:build` | `./gradlew build` |
| `kotlin:run` | `./gradlew run` (= application plugin 適用時のみ) |

## 依存

- Kotlin `>=1.9` (= `versions.yaml` 参照、 Gradle 8 系)
- Gradle (= wrapper 同梱推奨、 派生 repo で `gradle wrapper` 実行で生成)

## bump-targets 追加 (= init で append)

```yaml
- file: build.gradle.kts
  replacements:
    - search: 'version = "{OLD}"'
      replace: 'version = "{NEW}"'
```
