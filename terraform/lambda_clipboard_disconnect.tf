###
### clipboard_disconnect
###

resource "aws_lambda_function" "clipboard_disconnect" {
  function_name = local.clipboard_disconnect_name
  description = local.clipboard_disconnect_name
  handler       = "index.lambda_handler"
  runtime       = "nodejs16.x"
  timeout       = 5

  filename         = local.clipboard_disconnect_zip_file
  source_code_hash = data.archive_file.clipboard_disconnect.output_base64sha256
  role = aws_iam_role.clipboard_disconnect.arn

  environment {
    variables = {
      TABLE_NAME = module.dynamodb_table.dynamodb_table_id
    }
  }

  depends_on = [
    aws_cognito_user_pool.pool,
    aws_cloudwatch_log_group.clipboard_disconnect
  ]
}

data "archive_file" "clipboard_disconnect" {
  type        = "zip"
  source_dir = local.clipboard_disconnect_source_dir
  output_path = local.clipboard_disconnect_zip_file
}

resource "aws_lambda_permission" "clipboard_disconnect" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.clipboard_disconnect.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.clipboard.execution_arn}/*/*"
}


resource "aws_iam_role" "clipboard_disconnect" {
  name = "${local.clipboard_disconnect_name}-role"

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

resource "aws_iam_role_policy_attachment" "clipboard_disconnect" {
  role       = aws_iam_role.clipboard_disconnect.name
  policy_arn = aws_iam_policy.lambda_websocket.arn
}

resource "aws_cloudwatch_log_group" "clipboard_disconnect" {
  name = "/aws/lambda/${local.clipboard_disconnect_name}"
  retention_in_days = 7
}
