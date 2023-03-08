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

# module "lambda_clipboard_onconnect" {
#   source  = "terraform-aws-modules/lambda/aws"
#   version = "~> 4.10"

#   function_name = "${var.name}_clipboard_onconnect"
#   description   = "clipboard_onconnect"
#   handler       = "index.lambda_handler"
#   runtime       = "nodejs16.x"
#   environment_variables = tomap({"TABLE_NAME" = module.dynamodb_table.dynamodb_table_id})
#   source_path = "./lambda_clipboard_onconnect"
#   publish = true
#   attach_policy = true
#   # policy = "arn:aws:iam::aws:policy/AdministratorAccess"
#   policy = aws_iam_policy.lambda_websocket.arn
#   cloudwatch_logs_retention_in_days = 7
#   allowed_triggers = {
#     AllowExecutionFromAPIGateway = {
#       service    = "apigateway"
#       source_arn = "arn:aws:execute-api:${var.region}:${data.aws_caller_identity.current.account_id}:*"
#     }
#   } 
# }

# module "lambda_clipboard_disconnect" {
#   source  = "terraform-aws-modules/lambda/aws"
#   version = "~> 4.10"

#   function_name = "${var.name}_clipboard_disconnect"
#   description   = "clipboard_disconnect"
#   handler       = "index.lambda_handler"
#   runtime       = "nodejs16.x"
#   environment_variables = tomap({"TABLE_NAME" = module.dynamodb_table.dynamodb_table_id})
#   source_path = "./lambda_clipboard_disconnect"
#   publish = true
#   attach_policy = true
#   policy = aws_iam_policy.lambda_websocket.arn
#   cloudwatch_logs_retention_in_days = 7
#   allowed_triggers = {
#     AllowExecutionFromAPIGateway = {
#       service    = "apigateway"
#       source_arn = "arn:aws:execute-api:${var.region}:${data.aws_caller_identity.current.account_id}:*"
#     }
#   }
# }

# module "lambda_clipboard_sendmessage" {
#   source  = "terraform-aws-modules/lambda/aws"
#   version = "~> 4.10"

#   function_name = "${var.name}_clipboard_sendmessage"
#   description   = "clipboard_sendmessage"
#   handler       = "index.lambda_handler"
#   runtime       = "nodejs16.x"
#   environment_variables = tomap({"TABLE_NAME" = module.dynamodb_table.dynamodb_table_id})
#   source_path = "./lambda_clipboard_sendmessage"
#   publish = true
#   attach_policy = true
#   # policy = "arn:aws:iam::aws:policy/AdministratorAccess"
#   policy = aws_iam_policy.lambda_websocket.arn
#   cloudwatch_logs_retention_in_days = 7
#   allowed_triggers = {
#     AllowExecutionFromAPIGateway = {
#       service    = "apigateway"
#       source_arn = "arn:aws:execute-api:${var.region}:${data.aws_caller_identity.current.account_id}:*"
#     }
#   }
# }
