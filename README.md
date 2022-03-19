# これはなに？

dynamodb accelerator を使うことによって dynamodb のレイテンシーがどれほど下がるのかを実験するためのリポジトリ

# 構成

1. Lambda -> dynamoDB
2. Lambda -> DAX -> dynamoDB

トレースの監視は x-ray で行う。
