---
name: git-init
description: Initialize a project for first-time GitHub publishing by analyzing the project, proposing a repository name, preparing `.gitignore` and `README.md`, then setting up git, creating a GitHub repo, and pushing after user confirmation. Use for requests like "GitHubに上げたい", "リポジトリを作りたい", "初回公開したい", or when a repo exists locally without a configured remote.
---

# Git Init

GitHub へ初回公開するためのセットアップを進める skill。既に git リポジトリだが remote が未設定のケースも扱う。

## Step 0: Preconditions

最初に以下を確認する。

```bash
gh auth status
git rev-parse --is-inside-work-tree
git status --porcelain
git diff --cached --name-only
git remote -v
git branch --show-current
```

停止条件:

- `gh` が未インストールまたは未認証なら、`gh auth login` を案内して停止する。
- staged 済みの変更がある場合は、意図しない初回 commit 混入を防ぐため停止する。
- detached HEAD の場合は停止する。

記録すること:

- git 未初期化かどうか
- 未コミット変更の有無
- remote の有無と向き先
- 現在ブランチ名

## Step 1: Project Analysis

プロジェクトルートの設定ファイルを読んで、技術スタック、プロジェクト名、README の材料を推定する。

優先的に確認するファイル:

- `package.json`
- `Cargo.toml`
- `pyproject.toml`
- `setup.py`
- `requirements.txt`
- `go.mod`
- `pom.xml`
- `build.gradle`
- `*.csproj`
- `*.sln`

パッケージマネージャは lockfile から判定する。

- `pnpm-lock.yaml` -> pnpm
- `yarn.lock` -> yarn
- `bun.lock` / `bun.lockb` -> bun
- `poetry.lock` -> poetry
- `uv.lock` -> uv
- 上記がなければ npm / pip を既定とする

## Step 2: Repository Name Proposal

以下の優先順位でリポジトリ名を決める。

1. 設定ファイルの `name` 相当
2. ディレクトリ名

正規化ルール:

- kebab-case に変換する
- npm scope は落として本体名だけ使う
- 英数字と `-` のみ残す
- 連続した `-` は 1 つに圧縮する
- 先頭と末尾の `-` は除去する

`src`, `app`, `project`, `sample` のような汎用名しか得られない場合は、内容からより具体的な候補を提案する。

公開前に、提案した repo 名と公開設定が `public` か `private` かをユーザーに確認する。明示指定がなければ `public` を既定とする。

## Step 3: Prepare `.gitignore`

`.gitignore` の状態に応じて:

- ない場合は新規作成
- あるが不足がある場合は不足分だけ追記
- 既に十分なら変更しない

最低限の候補:

- 共通: `.env`, `.env.local`, `.env.*.local`, `.DS_Store`, `Thumbs.db`, `*.log`
- Node.js: `node_modules/`, `dist/`, `build/`, `.next/`
- Python: `__pycache__/`, `*.pyc`, `.venv/`, `venv/`, `dist/`, `*.egg-info/`
- Rust: `target/`
- Java: `target/`, `build/`, `.gradle/`, `*.class`

`.env` や秘密情報が追跡対象に入らないことを必ず確認する。

## Step 4: Prepare `README.md`

`README.md` は以下の方針で扱う。

- ない場合は新規作成
- 空またはタイトルだけのテンプレートなら補完
- 実質的な内容が既にあるなら触らない

生成する場合の基本構成:

```md
# プロジェクト名

概要

## 技術スタック

- ...

## セットアップ

1. clone
2. install
3. run
```

README は日本語で書く。

## Step 5: Git Setup and Commit

### git 未初期化の場合

```bash
git init
git branch -M main
```

この skill で生成または変更したファイルだけを add するのが原則だが、未初期化の新規プロジェクトで初回公開対象全体を commit する必要がある場合は、`.gitignore` と秘密情報の確認後に対象を明示して add する。

### git 初期化済みの場合

この skill が生成したファイルだけを明示的に add する。既存の未コミット変更は勝手に含めない。

コミット前に:

- 追加対象ファイル
- 除外対象ファイル
- コミットメッセージ案

を表示して確認する。既定の初回コミットメッセージは `initial commit` でよいが、README や `.gitignore` だけの補完なら内容に合わせて短く調整してよい。

## Step 6: Create GitHub Repo and Push

remote 状態に応じて分岐する。

- remote 未設定: `gh repo create <repo> --public|--private --source=. --remote=origin --push`
- `origin` が GitHub を向いている: `git push -u origin <branch>`
- `origin` が GitHub 以外: `origin` は残し、必要なら `github` など別名 remote を提案する
- `origin` がなく別 remote のみある: GitHub repo を作成して `origin` として追加する案を出す

GitHub 側の作成や push は外部副作用なので、実行直前に必ず確認する。

## Failure Handling

- repo 名衝突: 別名候補を提案する
- 認証エラー: `gh auth login` を案内する
- ネットワークエラー: 接続確認後の再実行を案内する
- 途中失敗時は、何が完了済みで何が未完了かを明示する

## Restrictions

- `git add -A` や `git add .` を無条件で使わない
- 既存の未コミット変更を勝手に初回 commit に混ぜない
- `git push --force` を自動実行しない
