
###
### cognito_deactivate_guest
###

resource "aws_lambda_function" "cognito_deactivate_guest" {
  function_name = local.cognito_deactivate_guest_name
  description = local.cognito_deactivate_guest_name
  handler       = "index.lambda_handler"
  runtime       = "python3.9"
  timeout       = 5

  filename         = local.cognito_deactivate_guest_zip_file
  source_code_hash = data.archive_file.cognito_deactivate_guest.output_base64sha256
  role = aws_iam_role.cognito_deactivate_guest.arn


  depends_on = [
    aws_cloudwatch_log_group.cognito_deactivate_guest
  ]
  
}

data "archive_file" "cognito_deactivate_guest" {
  type        = "zip"
  source_dir = local.cognito_deactivate_guest_source_dir
  output_path = local.cognito_deactivate_guest_zip_file
}

resource "aws_iam_role" "cognito_deactivate_guest" {
  name = "${local.cognito_deactivate_guest_name}-role"

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
    name = "lambda-policy"
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
        },
        {
          Sid = "S3ReadAccess"
          Effect = "Allow"
          Action = [
            "s3:GetObject"
          ]
          Resource = [
            "arn:aws:s3:::${aws_s3_bucket.account.id}/*"
          ]
        }        
      ]
    })
  }
}

resource "aws_cloudwatch_log_group" "cognito_deactivate_guest" {
  name = "/aws/lambda/${local.cognito_deactivate_guest_name}"
  retention_in_days = 7
}

resource "aws_lambda_permission" "cognito_deactivate_guest" {
  statement_id  = "AllowCognitoToInvokeFunction"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.cognito_deactivate_guest.function_name
  principal     = "cognito-idp.amazonaws.com"

  source_arn = aws_cognito_user_pool.pool.arn
}
