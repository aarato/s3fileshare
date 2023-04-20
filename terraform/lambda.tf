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
### WebSocket Lambda Functions
###

module "lambda_clipboard_onconnect" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "~> 4.10"

  function_name = "${var.name}_clipboard_onconnect"
  description   = "clipboard_onconnect"
  handler       = "index.lambda_handler"
  runtime       = "nodejs16.x"
  environment_variables = tomap({"TABLE_NAME" = module.dynamodb_table.dynamodb_table_id})
  source_path = "./lambda_clipboard_onconnect"
  publish = true
  attach_policy = true
  # policy = "arn:aws:iam::aws:policy/AdministratorAccess"
  policy = aws_iam_policy.lambda_websocket.arn
  cloudwatch_logs_retention_in_days = 7
  allowed_triggers = {
    AllowExecutionFromAPIGateway = {
      service    = "apigateway"
      source_arn = "arn:aws:execute-api:${var.region}:${data.aws_caller_identity.current.account_id}:*"
    }
  } 
}

module "lambda_clipboard_disconnect" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "~> 4.10"

  function_name = "${var.name}_clipboard_disconnect"
  description   = "clipboard_disconnect"
  handler       = "index.lambda_handler"
  runtime       = "nodejs16.x"
  environment_variables = tomap({"TABLE_NAME" = module.dynamodb_table.dynamodb_table_id})
  source_path = "./lambda_clipboard_disconnect"
  publish = true
  attach_policy = true
  policy = aws_iam_policy.lambda_websocket.arn
  cloudwatch_logs_retention_in_days = 7
  allowed_triggers = {
    AllowExecutionFromAPIGateway = {
      service    = "apigateway"
      source_arn = "arn:aws:execute-api:${var.region}:${data.aws_caller_identity.current.account_id}:*"
    }
  }
}

module "lambda_clipboard_sendmessage" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "~> 4.10"

  function_name = "${var.name}_clipboard_sendmessage"
  description   = "clipboard_sendmessage"
  handler       = "index.lambda_handler"
  runtime       = "nodejs16.x"
  environment_variables = tomap({"TABLE_NAME" = module.dynamodb_table.dynamodb_table_id})
  source_path = "./lambda_clipboard_sendmessage"
  publish = true
  attach_policy = true
  # policy = "arn:aws:iam::aws:policy/AdministratorAccess"
  policy = aws_iam_policy.lambda_websocket.arn
  cloudwatch_logs_retention_in_days = 7
  allowed_triggers = {
    AllowExecutionFromAPIGateway = {
      service    = "apigateway"
      source_arn = "arn:aws:execute-api:${var.region}:${data.aws_caller_identity.current.account_id}:*"
    }
  }
}


locals {
  create_cognito_user_name               = "${lower(var.name)}-${lower(var.app_environment)}-create_cognito_user"
  create_cognito_user_source_dir         = "${path.module}/aws_lambda_functions/create_cognito_user"
  create_cognito_user_zip_file           = "${path.module}/aws_lambda_functions/${local.create_cognito_user_name}.zip"
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
  cloudwatch_log_group_arn = aws_cloudwatch_log_group.create_cognito_user.arn
  
  depends_on = [
    aws_cognito_user_pool.pool,
    aws_cloudwatch_log_group.lambda_create_cognito_user
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