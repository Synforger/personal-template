# `_overlays/csharp/` — C# / .NET overlay

`task init` で **csharp overlay を選んだ場合** root に昇格する中身。 .NET class library 型 (= `*.csproj` SDK style)、 Unity / WPF は別 boilerplate。

## 構成

```
_overlays/csharp/
├── _README.md                  # このファイル
├── global.json                 # .NET SDK pin
├── MyCsharpLib.sln             # solution (= library + test 2 project)
├── src/MyCsharpLib.csproj      # library project
├── src/MyCsharpLib.cs          # library entry
├── tests/MyCsharpLib.Tests.csproj   # xUnit test project
├── tests/MyCsharpLibTests.cs   # xUnit 雛形
└── Taskfile.csharp.yml         # cs: namespace task
```

## task 一覧 (= `cs:` namespace)

| task | 中身 |
|---|---|
| `cs:setup` | `dotnet restore` |
| `cs:update` | `dotnet outdated -u` (= dotnet-outdated tool 必要、 optional) |
| `cs:lint` | `dotnet format --verify-no-changes` |
| `cs:test:unit` | `dotnet test --filter Category=Unit` |
| `cs:test:integration` | `dotnet test --filter Category=Integration` |
| `cs:build` | `dotnet build --configuration Release` |
| `cs:run` | `dotnet run --project src/MyCsharpLib.csproj` (= console プロジェクト時のみ) |

## 依存

- .NET SDK `>=8.0` (= `versions.yaml` 参照、 LTS)
- dotnet-format (= .NET SDK に同梱)
- dotnet-outdated (= optional、 `dotnet tool install --global dotnet-outdated-tool`)

## bump-targets 追加 (= init で append)

```yaml
- file: src/MyCsharpLib.csproj
  replacements:
    - search: '<Version>{OLD}</Version>'
      replace: '<Version>{NEW}</Version>'
```
