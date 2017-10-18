# dvc2mackerel.pl - ドトールバリューカード (Doutor Value Card) の残高・ポイント数をMackerelに投稿するPerlスクリプト

## What is this?

このPerlスクリプトは、プリペイドカードの一種である、[ドトールバリューカード (Doutor Value Card)](http://doutor.jp/) の残高・ポイント数を、クロールして取得し、サーバ管理・監視ツールの[Mackerel](https://mackerel.io/ja/)に投稿します。

私があまりにもドトールに通いすぎてDVCチャージを頻繁に行うので、残高・ポイント数の変動を可視化してみたくて作りました。

## USAGE

1. git clone https://github.com/mah-jp/dvc2mackerel
2. dvc2mackerel.ini を編集する
3. テストとして ``$ dvc2mackerel.pl -j`` を実行して、ドトールバリューカード (Doutor Value Card) の残高・ポイント数が標準出力されることを確認する
4. たとえば次のようなcronを設定すると、毎時00分と30分に、Mackerelにデータが投稿されるようになります

```
0,30 * * * * curl https://api.mackerelio.com/api/v0/services/+++++YOUR-SERVICE-NAME+++++/tsdb -H 'X-Api-Key: +++++YOUR-API-KEY+++++' -H 'Content-Type: application/json' -X POST -d "$(/path/to/dvc2mackerel.pl -i /path/to/dvc2mackerel.ini -j)"
```

## AUTHOR

大久保 正彦 (Masahiko OHKUBO) <[mah@remoteroom.jp](mailto:mah@remoteroom.jp)> <[https://twitter.com/mah_jp](https://twitter.com/mah_jp)>

## COPYRIGHT and LICENSE

This software is copyright (c) 2017 by Masahiko OHKUBO.

This is free software; you can redistribute it and/or modify it under the same terms as the Perl 5 programming language system itself.
