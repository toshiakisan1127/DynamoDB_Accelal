resource "aws_s3_bucket" "terraform-state-storage" {
  bucket = "catapp-terraform-state-storage"
  acl    = "private"

  versioning {
    enabled = true
  }
}

resource "aws_dynamodb_table" "terraform-state-lock" {
  name           = "terraform-state-lock"
  read_capacity  = 1
  write_capacity = 1
  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}
