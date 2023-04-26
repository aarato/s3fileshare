
###
### cognito_activate_guest
###

resource "aws_lambda_function" "cognito_activate_guest" {
  function_name = local.cognito_activate_guest_name
  description = local.cognito_activate_guest_name
  handler       = "index.lambda_handler"
  runtime       = "python3.9"
  timeout       = 5

  filename         = local.cognito_activate_guest_zip_file
  source_code_hash = data.archive_file.cognito_activate_guest.output_base64sha256
  role = aws_iam_role.cognito_activate_guest.arn

  environment {
    variables = {
      USER_POOL_ID = aws_cognito_user_pool.pool.id
    }
  }

  depends_on = [
    aws_cognito_user_pool.pool,
    aws_cloudwatch_log_group.cognito_activate_guest
  ]
}

data "archive_file" "cognito_activate_guest" {
  type        = "zip"
  source_dir = local.cognito_activate_guest_source_dir
  output_path = local.cognito_activate_guest_zip_file
}

resource "aws_iam_role" "cognito_activate_guest" {
  name = "${local.cognito_activate_guest_name}-role"

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

resource "aws_cloudwatch_log_group" "cognito_activate_guest" {
  name = "/aws/lambda/${local.cognito_activate_guest_name}"
  retention_in_days = 7
}


resource "aws_s3_bucket_notification" "cognito_activate_guest" {
  bucket = aws_s3_bucket.account.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.cognito_activate_guest.arn
    events              = ["s3:ObjectCreated:*"]
    # filter_prefix       = "files/guestpin.txt"
  }
  depends_on = [
    aws_s3_object.css
  ]
}


# resource "aws_lambda_event_source_mapping" "cognito_activate_guest" {
#   event_source_arn = "${aws_s3_bucket_notification.cognito_activate_guest.arn}"
#   function_name = "${aws_lambda_function.cognito_activate_guest.function_name}"
# }


resource "aws_lambda_permission" "s3_permission" {
  statement_id  = "AllowS3Invoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.cognito_activate_guest.id
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.account.arn
}

resource "aws_iam_policy" "cognito_activate_guest" {
  name = "lambda_s3_policy"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid = "S3TriggerLambda",
        Effect = "Allow",
        Action = [
          "lambda:InvokeFunction"
        ],
        Resource = [
          "${aws_lambda_function.cognito_activate_guest.arn}"
        ]
      },
      {
        Sid = "S3ReadObject",
        Effect = "Allow",
        Action = [
          "s3:GetObject",
          "s3:GetObjectVersion"
        ],
        Resource = [
          "${aws_s3_bucket.account.arn}/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "cognito_activate_guest" {
  policy_arn = "${aws_iam_policy.cognito_activate_guest.arn}"
  role = "${aws_iam_role.cognito_activate_guest.name}"
}
