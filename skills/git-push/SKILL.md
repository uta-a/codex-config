---
name: git-push
description: Review local git changes, classify staged and unstaged files, generate a Japanese Conventional Commits message, then commit and push after explicit confirmation. Use for requests like "pushして", "変更をpushして", "コミットしてpushして", or "GitHubに反映して". If the repository has no remote yet, stop and direct the user to `git-init`.
---

# Git Push

既存の git リポジトリで、変更確認、commit、push を安全に進める skill。

初回公開や remote 未設定のセットアップは `git-init` の責務とし、この skill では扱わない。

## Step 0: Preflight

以下を確認する。

```bash
git rev-parse --is-inside-work-tree
git remote -v
git branch --show-current
git status --short --branch
git fetch --quiet 2>/dev/null
git status --short --branch
```

停止条件:

- git リポジトリではない
- remote が未設定
- detached HEAD
- rebase / merge / cherry-pick / bisect / revert の途中

判定に使うパス:

- `.git/rebase-merge`
- `.git/rebase-apply`
- `.git/MERGE_HEAD`
- `.git/CHERRY_PICK_HEAD`
- `.git/BISECT_LOG`
- `.git/REVERT_HEAD`
- `.git/sequencer`

behind がある場合は、push が拒否される可能性を説明し、続行前に確認する。

## Step 1: Classify Changes

`git status --porcelain` を使って staged / modified / untracked を分類し、次も確認する。

```bash
git diff --cached --stat
git diff --stat
git ls-files --others --exclude-standard
```

表示形式の目安:

```text
--- 変更状況 ---
Staged (2):    src/auth.ts, src/utils.ts
Modified (1):  README.md
Untracked (1): src/new-feature.ts
```

変更がない場合は停止する。

同じファイルに staged と unstaged の両方がある場合は、部分ステージであることを明示し、staged 分だけで進めるか、追加で stage するかを確認する。

大規模変更の目安:

- 変更ファイル数 10 以上
- 総 diff 行数 300 以上
- 新規ファイル数 5 以上

大規模変更かつ `main` / `master` の場合は、新しいブランチ作成を提案する。

## Step 2: Decide Commit Scope

対象ファイルは必ず明示する。ユーザーの意図しないファイルを混ぜない。

- staged がある場合は、そのまま commit するか、追加ファイルを含めるか確認する
- staged がない場合は、変更ファイル一覧を見せて commit 対象を確認する
- rename / delete / mode change があれば表示する

## Step 3: Safety Checks

### Filename-based warnings

以下が含まれていたら警告する。

- `.env`, `.env.*`
- `credentials.*`, `secret*`
- `*.pem`, `*.key`, `*.p12`, `*.pfx`
- `id_rsa*`, `id_ed25519*`
- `*.keystore`, `*.jks`
- `.npmrc`, `.pypirc`, `credentials.json`, `service-account*.json`

### Diff-based secret scan

対象 diff に対して以下を確認する。

- `AKIA` で始まる AWS キー
- `ghp_`, `gho_`, `ghu_`, `ghs_`, `ghr_`
- `sk-` で始まる長い API キー
- `password=`, `secret=`, `token=`, `api_key=`
- `Bearer ` トークン
- `-----BEGIN ... PRIVATE KEY-----`

### Large files and binaries

- 100MB を超えるファイルは警告する
- バイナリファイルは意図した変更か確認する

警告が出た場合は、除外して続行する案を最初に提示する。

## Step 4: Generate Commit Message

対象 diff を読み、Conventional Commits 形式の日本語メッセージを作る。

```text
<type>(<scope>): <日本語の要約>

<body: 必要な場合のみ>

<footer: 必要な場合のみ>
```

`type` の候補:

- `feat`
- `fix`
- `docs`
- `style`
- `refactor`
- `test`
- `chore`
- `perf`
- `ci`
- `build`

判断はファイル名だけでなく diff 内容を見る。

body を付ける目安:

- 変更ファイルが 3 つ以上
- diff が 50 行以上
- 破壊的変更がある
- 複数の論点を含む

必要なら `git log --oneline -10` を見て、そのリポジトリの message 傾向に合わせる。

## Step 5: Confirm Commit and Push

commit と push はまとめて 1 回で確認する。

確認が必要な場合は、plan モードと同じ構造化質問を優先する。つまり `request_user_input` が使える環境では、自由入力の plain text ではなく、短い選択肢つきの確認 UI を使う。

確認 UI の原則:

- 質問は 1 回につき 1 件を基本にする
- 選択肢は 2 から 3 個に絞る
- 推奨案を先頭に置き、`(Recommended)` を付ける
- 対象ファイル、除外ファイル、commit message、push 先、保護ブランチ警告など判断に必要な要約を質問の直前に示す
- `commit` と `push` をまとめて実行する案と、`commit` のみで止める案を同じ確認内で出す
- メッセージ修正や対象ファイルの見直しが必要なら戻れるようにする

`request_user_input` が使えない環境だけ、通常のテキスト確認にフォールバックする。

確認前に表示する内容:

```text
--- commit / push 内容 ---
対象ファイル: ...
除外ファイル: ...

コミットメッセージ:
  feat(auth): ...

push 先:
  <remote>/<branch>

保護ブランチ警告:
  main
```

保護ブランチとして特に警告する候補:

- `main`, `master`
- `release/*`, `release-*`
- `develop`, `development`
- `production`, `staging`

確認の選択肢例:

- `Commit and push (Recommended)`: 表示した対象ファイルと message で commit し、そのまま表示先へ push する
- `Commit only`: push せず、ローカル commit のみで止める
- `Review files`: 対象ファイルまたは message を見直して Step 2 に戻る

## Step 6: Execute

必要なファイルだけを明示的に add する。

```bash
git add <file1> <file2> ...
git commit -m "<message>"
git push
git push -u origin <branch>
```

複数行メッセージが必要なら、一時ファイルか複数 `-m` を使って安全に渡す。hook 回避のため `--no-verify` は使わない。

## Restrictions

- `git push --force` や `--force-with-lease` を自動実行しない
- `--no-verify` を使わない
- `git add -A` や `git add .` を無条件で使わない
- hook 失敗を勝手にスキップしない

## Failure Handling

hook 失敗時:

- エラー内容を表示する
- commit 未実行であることを明示する
- 修正案があれば提示する

push 失敗時:

- commit はローカルに残っていることを明示する
- 原因に応じて案内する

代表例:

- non-fast-forward: `git pull` 系の調整が必要
- 認証エラー: `gh auth login` を案内
- ブランチ保護: PR フローを案内
- ネットワークエラー: 接続確認後の再試行を案内
