
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


data "aws_iam_policy_document" "dax_full_access_policy_document" {
  statement {
    actions = [
      "dax:*"
    ]
    resources = [
      aws_dax_cluster.test_dax_cluster.arn
    ]
    effect = "Allow"
  }
}

resource "aws_iam_policy" "dax_full_access_policy" {
  name   = "dax_full_access_policy"
  policy = data.aws_iam_policy_document.dax_full_access_policy_document.json
}

resource "aws_iam_role_policy_attachment" "aws_dax_full_access" {
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = aws_iam_policy.dax_full_access_policy.arn
}

resource "aws_dax_cluster" "test_dax_cluster" {
  cluster_name       = "cluster-example"
  iam_role_arn       = aws_iam_role.iam_role_for_dax.arn
  node_type          = "dax.r4.large"
  replication_factor = 1
  availability_zones = ["ap-northeast-1a"]
}
