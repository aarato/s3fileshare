
###
### cognito_change_pass
###

resource "aws_lambda_function" "cognito_change_pass" {
  function_name = local.cognito_change_pass_name
  description = local.cognito_change_pass_name
  handler       = "index.lambda_handler"
  runtime       = "python3.9"
  timeout       = 5

  filename         = local.cognito_change_pass_zip_file
  source_code_hash = data.archive_file.cognito_change_pass.output_base64sha256
  role = aws_iam_role.cognito_change_pass.arn

  depends_on = [
    aws_cognito_user_pool.pool,
    aws_cloudwatch_log_group.cognito_change_pass
  ]
}

data "archive_file" "cognito_change_pass" {
  type        = "zip"
  source_dir = local.cognito_change_pass_source_dir
  output_path = local.cognito_change_pass_zip_file
}

resource "aws_iam_role" "cognito_change_pass" {
  name = "${local.cognito_change_pass_name}-role"

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

resource "aws_cloudwatch_log_group" "cognito_change_pass" {
  name = "/aws/lambda/${local.cognito_change_pass_name}"
  retention_in_days = 7
}



