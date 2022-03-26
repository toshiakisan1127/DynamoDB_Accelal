variable "lambda_function_name" {
  default = "test_lambda_function"
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

  vpc_config {
    subnet_ids         = var.dax_subnet_ids
    security_group_ids = var.dax_security_group_ids
  }

  timeout = 10
}

resource "aws_cloudwatch_log_group" "cloudwatch_logs" {
  name              = "/aws/lambda/${var.lambda_function_name}"
  retention_in_days = 14
}
