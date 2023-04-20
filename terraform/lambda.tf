###
### CREATE ADMIN COGNITO USER
###

data "aws_lambda_invocation" "create_admin" {
  function_name = module.lambda_create_cognito_user.lambda_function_name

  input = <<JSON
{
  "userpoolid": "${aws_cognito_user_pool.pool.id}",
  "username": "admin",
  "password": "${var.password}"
}
JSON
}

module "lambda_create_cognito_user" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "~> 4.10"

  function_name = "${var.name}_lambda_create_cognito_user"
  description   = "lambda_create_cognito_user"
  handler       = "index.lambda_handler"
  runtime       = "python3.8"
  use_existing_cloudwatch_log_group = true
  source_path = "./lambda_create_cognito_user"
  cloudwatch_logs_retention_in_days = 7
  publish = true
  attach_policy = true
  policy = "arn:aws:iam::aws:policy/AmazonCognitoPowerUser"
  depends_on = [
    aws_cognito_user_pool.pool,
    aws_cloudwatch_log_group.lambda_create_cognito_user
  ]
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
  function_name               = "${lower(var.app_name)}-${lower(var.app_environment)}-function1"
  function_handler            = "index.lambda_handler"
  function_runtime            = "python3.9"
  function_source_dir = "${path.module}/aws_lambda_functions/function1"
  function_zip_file   = "${path.module}/aws_lambda_functions/${local.function_name}.zip"
  function_timeout_in_seconds = 5
}


resource "aws_lambda_function" "function" {
  function_name = local.function_name
  handler       = "index.lambda_handler"
  runtime       = "python3.9"
  timeout       = 5

  filename         = local.function_zip_file
  source_code_hash = data.archive_file.function_zip.output_base64sha256
  role = aws_iam_role.function_role.arn
  depends_on = [
    aws_cognito_user_pool.pool,
    aws_cloudwatch_log_group.lambda_create_cognito_user
  ]
}

data "archive_file" "function_zip" {
  type        = "zip"
  source_dir = local.function_source_dir
  output_path = local.function_zip_file
}

resource "aws_iam_role" "function_role" {
  name = "${local.function_name}-role"

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
    name = "${local.function_name}-user-logs"
    policy = <<EOF
{
    "Version": "2012-10-17"
    "Statement": [
        {
            "Action": [
                "logs:PutLogEvents",
                "logs:CreateLogStream"
            ],
            "Effect": "Allow",
            "Resource": [*],
            "Sid": ""
        }
    ],
    
}
EOF
  }
}