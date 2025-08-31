# このリポジトリについて

京都工芸繊維大学の学生を対象とした奨学金一覧へのアクセスを便利にした Web アプリ「[KIT クレクレ奨学金](https://www.kit-gimme-scholarship.com/)(現在停止中)」のインフラのリポジトリです．

**バックエンド**: https://github.com/acu4git/gimme-scholarship/<br>
**フロントエンド**: https://github.com/acu4git/gimme-scholarship-front/

## 開発環境

- Ubuntu 22.04.5 (WSL2)
- Terraform v1.8.0

## インフラ構築

AWS リソースのほぼ全てを Terraform で構築しています(一部コンソール上で管理)．plan, apply を手動で行い更新しています．

また，一部 Cloudflare の DNS 設定も行っています．

## アーキテクチャ図

こちらを参照 ↓<br>
https://github.com/acu4git/gimme-scholarship/?tab=readme-ov-file#%E3%82%A2%E3%83%BC%E3%82%AD%E3%83%86%E3%82%AF%E3%83%81%E3%83%A3%E5%9B%B3

## その他

- なるべくマルチ AZ の構築を行っているが，金銭的な関係でほぼシングル AZ と同等の環境となっている．
- 突貫工事のような実装になってしまったため，モジュール化などを行い適切なディレクトリ構成に修正したい．
- バッチタスクは Step Functions を用いると起動失敗したときにも確実にタスクを実行できるが，エラーが発生したら手動で起動し直す方針を取っている．
