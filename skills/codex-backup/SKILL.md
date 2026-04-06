---
name: codex-backup
description: Back up `~/.codex/` configuration and custom skills to the GitHub `codex-config` repository with a `backup:` commit message, after checking git state and excluding sensitive files by default. Use for requests like "Codex設定をバックアップ", "configを保存", "codex-configに反映", or "設定変更をpushしたい".
---

# Codex Backup

`~/.codex/` 配下の設定や custom skills を、GitHub の `codex-config` リポジトリへ commit と push するための skill。

この skill は汎用 `git-push` ではなく、対象ディレクトリ、コミット prefix、機密ファイル除外方針を固定したバックアップ専用フローを担当する。

## Step 0: Preconditions

作業ディレクトリは `~/.codex/` に固定する。

最初に確認する。

```bash
git -C ~/.codex rev-parse --is-inside-work-tree
git -C ~/.codex remote get-url origin
git -C ~/.codex branch --show-current
git -C ~/.codex fetch --quiet 2>/dev/null
git -C ~/.codex status --short --branch
```

停止または分岐条件:

- git リポジトリでない場合:
  - `.codex` は現状 Git 管理されていない可能性がある
  - その場合は、この skill では commit/push を続けず、まず `git-init` 相当の初回セットアップを案内する
- `origin` が想定外の場合:
  - `uta-a/codex-config` ではない remote を検出したら、現在値を表示して続行可否を確認する
- detached HEAD や rebase/merge 中は停止する
- behind がある場合は、先に同期が必要な可能性を説明して確認する

## Step 1: Detect and Classify Changes

```bash
git -C ~/.codex status --porcelain
```

変更がない場合は停止する。

変更がある場合は staged / unstaged / untracked を分類して表示する。

表示例:

```text
--- ~/.codex 変更状況 ---
更新 (2):   config.toml, skills/git-push/SKILL.md
追加 (1):   skills/codex-backup/SKILL.md
削除 (0):   なし
```

## Step 2: Default Exclusions and Safety Checks

`~/.codex` には機密性の高いファイルが混ざりやすい。以下は既定で除外候補として扱い、含める場合のみ明示確認にする。

- `auth.json`
- `history.jsonl`
- `logs_*.sqlite`
- `state_*.sqlite`
- `*.sqlite-shm`
- `*.sqlite-wal`
- `sessions/`
- `log/`
- `tmp/`
- `.tmp/`

追加の警告対象:

- `.env`, `.env.*`
- `credentials.*`, `secret*`
- `*.pem`, `*.key`, `*.p12`, `*.pfx`
- API キーやトークンを含む diff

特に `config.toml` や custom skills の diff は、秘密情報を直書きしていないか確認する。

警告時の原則:

- 最初の提案は「該当ファイルを除外して続行」
- 含める場合は、機密性と公開先を再確認する

## Step 3: Build Backup Commit Message

コミットメッセージは常に `backup:` で始める。

形式:

```text
backup: <変更の要約>
```

例:

- `backup: config.toml を更新`
- `backup: skills/git-push と AGENTS.md を更新`
- `backup: skills/ を一括更新`

変更ファイルが多い場合だけ body を付ける。

```text
backup: skills/ を一括更新

変更ファイル:
- skills/git-init/SKILL.md: 追加
- skills/git-push/SKILL.md: 更新
```

## Step 4: Confirm Backup Scope

確認が必要な場合は、plan モードと同じ構造化質問を優先する。つまり `request_user_input` が使える環境では、自由入力の plain text ではなく、短い選択肢つきの確認 UI を使う。

確認 UI の原則:

- 質問は 1 回につき 1 件を基本にする
- 選択肢は 2 から 3 個に絞る
- 推奨案を先頭に置き、`(Recommended)` を付ける
- `commit` と `push` は必ず別々に確認する
- 対象ファイル、除外ファイル、message、push 先など判断に必要な要約を質問の直前に示す

`request_user_input` が使えない環境だけ、通常のテキスト確認にフォールバックする。

commit 前に以下を表示して確認する。

```text
--- backup 内容 ---
対象ファイル: ...
除外ファイル: ...

コミットメッセージ:
  backup: ...
```

`commit` 確認の選択肢例:

- `Commit now (Recommended)`: 表示した対象ファイルと message で commit する
- `Edit message`: message を調整して再確認する
- `Review files`: 対象ファイルを見直す

commit 後は push 先を明示して、push 実行前に再確認する。

```text
push 先: origin/<branch> (uta-a/codex-config)
```

`push` 確認の選択肢例:

- `Push now (Recommended)`: 現在の commit を `uta-a/codex-config` へ push する
- `Commit only`: push せず、ローカル commit のみで止める
- `Cancel`: ここで止める

## Step 5: Execute

対象ファイルだけを明示的に add する。

```bash
git -C ~/.codex add <file1> <file2> ...
git -C ~/.codex commit -m "<message>"
git -C ~/.codex push
git -C ~/.codex push -u origin <branch>
```

## Restrictions

- `git add -A` や `git add .` を無条件に使わない
- `git push --force` を自動実行しない
- `--no-verify` で hook を飛ばさない
- 機密ファイルを既定で含めない

## Failure Handling

- push 失敗時は、commit がローカルに残っているかを明示する
- remote 不一致時は、現在の URL を表示して判断を求める
- git 未初期化なら、この skill では初期化を進めず、先に Git 管理対象として整備するよう案内する
