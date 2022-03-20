resource "aws_dynamodb_table" "test_dynamodb_table" {
  name           = "dax_test_table"
  billing_mode   = "PROVISIONED"
  read_capacity  = 10
  write_capacity = 10
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

resource "aws_iam_role" "iam_role_for_dax" {
  name               = "test_iam_role_for_dax"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "dax.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "example" {
  role       = aws_iam_role.iam_role_for_dax.name
  policy_arn = aws_iam_policy.dynamodb_full_access_policy.arn
}

resource "aws_dax_cluster" "test_dax_cluster" {
  cluster_name       = "cluster-example"
  iam_role_arn       = aws_iam_role.iam_role_for_dax.arn
  node_type          = "dax.r4.large"
  replication_factor = 1
}
