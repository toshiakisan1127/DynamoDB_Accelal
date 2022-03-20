# これはなに？

dynamodb accelerator を使うことによって dynamodb のレイテンシーがどれほど下がるのかを実験するためのリポジトリ

# 構成

1. Lambda -> dynamoDB
2. Lambda -> DAX -> dynamoDB

トレースの監視は x-ray で行う。

# 結果

条件: lambda->dynamodb で

- put5 回, get10 回, delete5 回行なった。
- table は provisioned mode で、read_capacity=1, write_capacity=1
  [DAX を使わない場合のトレース](<https://ap-northeast-1.console.aws.amazon.com/cloudwatch/home?config=%7B%22displayMode%22%3A%22static%22%2C%22heightUnit%22%3A40%2C%22widgetMarginX%22%3A10%2C%22widgetMarginY%22%3A10%2C%22embeddedMaximize%22%3Afalse%2C%22style%22%3A%22polaris%22%7D&region=ap-northeast-1&origin=https%3A%2F%2Fap-northeast-1.console.aws.amazon.com%2Flambda%2Fhome&v=1#servicelens:traces/1-6236e9bd-79b79c842f4572630417b8ae?~(query~(filter~(node~'*7e*28name*7e*27test_lambda_function*7etype*7e*27AWS*2a3a*2a3aLambda*2a3a*2a3aFunction*7edataSource*7e*27xray*29))~context~())>)

read_capacity=10, write_capacity=10 に変えると次のようになった。変わらない。
[DAX を使わない場合のトレース(capacity=10)](<https://ap-northeast-1.console.aws.amazon.com/cloudwatch/home?config=%7B%22displayMode%22%3A%22static%22%2C%22heightUnit%22%3A40%2C%22widgetMarginX%22%3A10%2C%22widgetMarginY%22%3A10%2C%22embeddedMaximize%22%3Afalse%2C%22style%22%3A%22polaris%22%7D&region=ap-northeast-1&origin=https%3A%2F%2Fap-northeast-1.console.aws.amazon.com%2Flambda%2Fhome&v=1#servicelens:traces/1-6236ec30-1a9a4f37362c6e49602d1a1c?~(query~(filter~(node~'*7e*28name*7e*27test_lambda_function*7etype*7e*27AWS*2a3a*2a3aLambda*2a3a*2a3aFunction*7edataSource*7e*27xray*29))~context~())>)
