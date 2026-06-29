# `_overlays/node/` — Node.js / TypeScript overlay

`task init` で **node overlay を選んだ場合** root に昇格する中身。 library + CLI 兼用、 TypeScript デフォルト ON。 npm がデフォルト package manager (= pnpm / yarn への乗り換えは派生後に手動)。

## 構成

```
_overlays/node/
├── _README.md              # このファイル
├── package.json            # name placeholder + bin + exports
├── tsconfig.json           # strict TS 設定
├── .eslintrc.json          # eslint (TS + recommended)
├── .prettierrc             # prettier (= eslint と分離)
├── src/index.ts            # library + CLI entry
├── tests/index.test.ts     # vitest 雛形
└── Taskfile.node.yml       # node: namespace task
```

## task 一覧 (= `node:` namespace)

| task | 中身 |
|---|---|
| `node:setup` | `npm install` |
| `node:update` | `npm update` |
| `node:lint` | `npm run lint` (= eslint + prettier --check) |
| `node:test:unit` | `npm run test:unit` (= vitest run) |
| `node:test:integration` | `npm run test:integration` |
| `node:build` | `npm run build` (= tsc) |
| `node:run` | `npm start` |

## 依存

- Node.js `>=20.0` (= `versions.yaml` 参照、 LTS)
- npm (= Node.js に同梱)

## bump-targets 追加 (= init で append)

```yaml
- file: package.json
  replacements:
    - search: '"version": "{OLD}"'
      replace: '"version": "{NEW}"'
```
