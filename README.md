# codex-config

Codex のローカル設定と custom skills をバックアップするためのリポジトリです。

## 含めるもの

- `config.toml`
- `skills/`

## 含めないもの

- 認証情報
- 会話履歴
- セッションログ
- SQLite の状態ファイル
- 一時ファイルやキャッシュ

## 注意

このリポジトリを公開すると、`config.toml` に含まれるローカルのパス情報も公開されます。
