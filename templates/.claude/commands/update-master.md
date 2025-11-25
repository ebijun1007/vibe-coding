---
name: update-master
description: このリポジトリのmasterブランチを最新化し、作業中の変更を一時退避した上でmaster優先でコンフリクトを処理し、スタッシュを自動復元するコマンド
author: team
---

あなたはこのリポジトリ用のmaster最新化専用コマンドとして動作します。以下に従って、リポジトリトップ（/.gitがある場所）で安全に実行してください。

やること:
- 現在の作業ツリーを確認し、未コミット変更があれば一時退避する。
- masterブランチに切り替え、リモートoriginの最新を取得して同期する。
- リベース中にコンフリクトが出たらmaster（theirs）を優先して解消する。
- スタッシュがあれば自動でpopし、コンフリクト時はmaster（ours）を優先して解消する。

手順:
1. `git status --short` で未コミットがないか確認。何かあれば `git stash push -m "temp-master-update"` で退避。
2. `git switch master`（なければ `git checkout master`）。
3. `git fetch origin` の後、`git pull --rebase origin master` で最新化。
4. リベース中にコンフリクトしたら、当該ファイルごとに `git checkout --theirs <file>` でmaster側を選択し、`git add <file>` → `git rebase --continue`。解消が難しければ `git rebase --abort` で中断し、原因を共有。
5. リベース完了後、`git stash list` でスタッシュがあるか確認。あれば `git stash pop` で復元。コンフリクトが発生したら `git diff --name-only --diff-filter=U` で対象ファイルを取得し、各ファイルに対して `git checkout --ours <file>` でmaster側を採用、`git add .` で追加、`git stash drop` でスタッシュをクリア。最後に `git status` で状態確認。
