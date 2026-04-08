###
### AUTH PROXY — HTTP API Gateway + Lambda
### Proxies Cognito auth so the browser avoids CORS restrictions on cognito-idp
###

resource "aws_apigatewayv2_api" "auth_proxy" {
  name          = "${local.name}_auth_proxy"
  protocol_type = "HTTP"

  cors_configuration {
    allow_origins = ["*"]
    allow_methods = ["POST"]
    allow_headers = ["content-type"]
    max_age       = 300
  }
}

resource "aws_apigatewayv2_integration" "auth_proxy" {
  api_id                 = aws_apigatewayv2_api.auth_proxy.id
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.auth_proxy.invoke_arn
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "auth_proxy" {
  api_id    = aws_apigatewayv2_api.auth_proxy.id
  route_key = "POST /auth"
  target    = "integrations/${aws_apigatewayv2_integration.auth_proxy.id}"
}

resource "aws_apigatewayv2_stage" "auth_proxy" {
  api_id      = aws_apigatewayv2_api.auth_proxy.id
  name        = "$default"
  auto_deploy = true
}

resource "aws_lambda_permission" "auth_proxy" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.auth_proxy.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.auth_proxy.execution_arn}/*/*"
}

resource "aws_lambda_function" "auth_proxy" {
  function_name    = local.auth_proxy_name
  description      = local.auth_proxy_name
  handler          = "index.lambda_handler"
  runtime          = "python3.12"
  timeout          = 10
  filename         = local.auth_proxy_zip_file
  source_code_hash = data.archive_file.auth_proxy.output_base64sha256
  role             = aws_iam_role.auth_proxy.arn

  environment {
    variables = {
      COGNITO_CLIENT_ID = aws_cognito_user_pool_client.client.id
      REGION            = var.region
    }
  }

  depends_on = [aws_cloudwatch_log_group.auth_proxy]
}

data "archive_file" "auth_proxy" {
  type        = "zip"
  source_dir  = local.auth_proxy_source_dir
  output_path = local.auth_proxy_zip_file
}

resource "aws_iam_role" "auth_proxy" {
  name = "${local.auth_proxy_name}-role"

  assume_role_policy = jsonencode({
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy" "auth_proxy_logs" {
  name = "lambda-logs-policy"
  role = aws_iam_role.auth_proxy.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"]
      Resource = "arn:aws:logs:*:*:*"
    }]
  })
}

resource "aws_iam_role_policy" "auth_proxy_cognito" {
  name = "cognito-auth-policy"
  role = aws_iam_role.auth_proxy.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["cognito-idp:InitiateAuth"]
      Resource = aws_cognito_user_pool.pool.arn
    }]
  })
}

resource "aws_cloudwatch_log_group" "auth_proxy" {
  name              = "/aws/lambda/${local.auth_proxy_name}"
  retention_in_days = 7
}
