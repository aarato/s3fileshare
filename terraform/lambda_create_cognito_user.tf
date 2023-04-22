###
### CREATE ADMIN COGNITO USER
###

data "aws_lambda_invocation" "create_admin" {
  # function_name = module.lambda_create_cognito_user.lambda_function_name
  function_name = aws_lambda_function.create_cognito_user.function_name

  input = <<JSON
{
  "userpoolid": "${aws_cognito_user_pool.pool.id}",
  "username": "admin",
  "password": "${var.password}"
}
JSON
}


###
### create_cognito_user
###

resource "aws_lambda_function" "create_cognito_user" {
  function_name = local.create_cognito_user_name
  description = local.create_cognito_user_name
  handler       = "index.lambda_handler"
  runtime       = "python3.9"
  timeout       = 5

  filename         = local.create_cognito_user_zip_file
  source_code_hash = data.archive_file.create_cognito_user.output_base64sha256
  role = aws_iam_role.create_cognito_user.arn

  depends_on = [
    aws_cognito_user_pool.pool,
    aws_cloudwatch_log_group.create_cognito_user
  ]
}

data "archive_file" "create_cognito_user" {
  type        = "zip"
  source_dir = local.create_cognito_user_source_dir
  output_path = local.create_cognito_user_zip_file
}

resource "aws_iam_role" "create_cognito_user" {
  name = "${local.create_cognito_user_name}-role"

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

resource "aws_cloudwatch_log_group" "create_cognito_user" {
  name = "/aws/lambda/${local.create_cognito_user_name}"
  retention_in_days = 7
}


