resource "aws_dynamodb_table" "test_dynamodb_table" {
  name           = "dax_test_table"
  billing_mode   = "PROVISIONED"
  read_capacity  = 1
  write_capacity = 1
  hash_key       = "UserId"

  attribute {
    name = "UserId"
    type = "S"
  }

  tags = {
    Name        = "env"
    Environment = "test"
  }
}
