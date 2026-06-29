# Ops

利用者向けの運用 / トラブルシュート / 常駐 service 管理を書く section。 派生プロジェクトで具体内容を埋める。

## 推奨構成

- **runbook.md** — 日常運用 (= 起動 / 停止 / バックアップ / ログ確認 / アップデート)
- **troubleshoot.md** — よくある不具合 + 対処 (= 1 問題 1 section、 「症状」 → 「原因」 → 「対処」 の三段)
- **launchd-systemd.md** — 常駐 service として動かす場合の設定 (= launchd plist / systemd unit / pm2 ecosystem 等)
- **backup.md** — 物理 backup の対象 file / 頻度 / 復元手順

`task install-service` / `task restart` / `task logs` 等の運用 task が overlay に含まれる場合、 ここから link する。
