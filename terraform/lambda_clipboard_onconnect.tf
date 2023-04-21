###
### clipboard_onconnect
###

resource "aws_lambda_function" "clipboard_onconnect" {
  function_name = local.clipboard_onconnect_name
  description = local.clipboard_onconnect_name
  handler       = "index.lambda_handler"
  runtime       = "nodejs16.x"
  timeout       = 5

  filename         = local.clipboard_onconnect_zip_file
  source_code_hash = data.archive_file.clipboard_onconnect.output_base64sha256
  role = aws_iam_role.lambda_websocket.arn

  depends_on = [
    aws_cognito_user_pool.pool,
    aws_cloudwatch_log_group.clipboard_onconnect
  ]
}

data "archive_file" "clipboard_onconnect" {
  type        = "zip"
  source_dir = local.clipboard_onconnect_source_dir
  output_path = local.clipboard_onconnect_zip_file
}

resource "aws_iam_role" "clipboard_onconnect" {
  name = "${local.clipboard_onconnect_name}-role"

  assume_role_policy = jsonencode({
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      },
    ]
  })
  managed_policy_arns = ["arn:aws:iam::aws:policy/AmazonCognitoPowerUser"]
  inline_policy {
    name = "lambda-logs-policy"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Effect   = "Allow"
          Action   = [
            "logs:CreateLogGroup",
            "logs:CreateLogStream",
            "logs:PutLogEvents"
          ]
          Resource = "arn:aws:logs:*:*:*"
        }
      ]
    })
  }
}

resource "aws_cloudwatch_log_group" "clipboard_onconnect" {
  name = "/aws/lambda/${local.clipboard_onconnect_name}"
  retention_in_days = 7
}
