variable "lambda_function_name" {
  default = "test_lambda_function"
}

resource "aws_iam_role" "iam_for_lambda" {
  name = "iam_for_lambda"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_policy" "lambda_logging" {
  name        = "lambda_logging"
  path        = "/"
  description = "IAM policy for logging from a lambda"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "arn:aws:logs:*:*:*",
      "Effect": "Allow"
    }
  ]
}
EOF
}

data "archive_file" "lambda_function_payload" {
  type        = "zip"
  source_dir  = "${path.module}/package"
  output_path = "${path.module}/build/lambda_function_payload.zip"
}

resource "aws_lambda_function" "test_lambda" {
  depends_on = [
    data.archive_file.lambda_function_payload,
    aws_cloudwatch_log_group.cloudwatch_logs,
    aws_iam_role_policy_attachment.lambda_logs

  ]
  filename      = data.archive_file.lambda_function_payload.output_path
  function_name = var.lambda_function_name
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "lambda_function.lambda_handler"

  # The filebase64sha256() function is available in Terraform 0.11.12 and later
  # For Terraform 0.11.11 and earlier, use the base64sha256() function and the file() function:
  # source_code_hash = "${base64sha256(file("lambda_function_payload.zip"))}"
  source_code_hash = filebase64sha256(data.archive_file.lambda_function_payload.output_path)

  runtime = "python3.8"

  environment {
    variables = {
      "DAX_URL" = aws_dax_cluster.test_dax_cluster.configuration_endpoint
    }
  }

  tracing_config {
    mode = "Active"
  }

  timeout = 10
}

resource "aws_cloudwatch_log_group" "cloudwatch_logs" {
  name              = "/aws/lambda/${var.lambda_function_name}"
  retention_in_days = 14
}

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = aws_iam_policy.lambda_logging.arn
}

resource "aws_iam_role_policy_attachment" "aws_xray_write_only_access" {
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = "arn:aws:iam::aws:policy/AWSXrayWriteOnlyAccess"
}

# dynamodbへのフルアクセス
data "aws_iam_policy_document" "dynamodb_full_access_policy_document" {
  statement {
    actions = [
      "dynamodb:BatchGet*",
      "dynamodb:DescribeStream",
      "dynamodb:DescribeTable",
      "dynamodb:Get*",
      "dynamodb:Query",
      "dynamodb:Scan",
      "dynamodb:BatchWrite*",
      "dynamodb:CreateTable",
      "dynamodb:Delete*",
      "dynamodb:Update*",
      "dynamodb:PutItem"
    ]
    resources = [
      aws_dynamodb_table.test_dynamodb_table.arn
    ]
    effect = "Allow"
  }
}

resource "aws_iam_policy" "dynamodb_full_access_policy" {
  name   = "dynamodb_full_access_policy"
  policy = data.aws_iam_policy_document.dynamodb_full_access_policy_document.json
}

resource "aws_iam_role_policy_attachment" "aws_dynamodb_full_access" {
  role       = aws_iam_role.iam_for_lambda.name
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
