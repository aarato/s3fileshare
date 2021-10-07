###
###  USED BY API GATEWAY ACCOUNT
###

resource "aws_iam_role" "cloudwatch" {
  name = "${var.name}_api_gateway_cloudwatch_global"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "apigateway.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "cloudwatch" {
  name = "${var.name}_default"
  role = aws_iam_role.cloudwatch.id

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:DescribeLogGroups",
                "logs:DescribeLogStreams",
                "logs:PutLogEvents",
                "logs:GetLogEvents",
                "logs:FilterLogEvents"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}


###
### USED BY COGNITO
###

resource "aws_iam_role" "cognito_authenticated" {
  name = "${var.name}_cognito_authenticated"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "cognito-identity.amazonaws.com"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "cognito-identity.amazonaws.com:aud": "${aws_cognito_identity_pool.id_pool.id}"
        },
        "ForAnyValue:StringLike": {
          "cognito-identity.amazonaws.com:amr": "authenticated"
        }
      }
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "cognito_policy" {
  name = "${var.name}_cognito_policy"
  role = aws_iam_role.cognito_authenticated.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "mobileanalytics:PutEvents",
        "cognito-sync:*",
        "cognito-identity:*"
      ],
      "Resource": [
        "*"
      ]
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "s3_access_to_folder" {
  name = "${var.name}_s3_access_to_folder"
  role = aws_iam_role.cognito_authenticated.id

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "ListBucketRules",
            "Effect": "Allow",
            "Action": [
                "s3:ListBucketVersions",
                "s3:ListBucket"
            ],
            "Resource": "arn:aws:s3:::${var.name}",
            "Condition": {
                "StringLike": {
                    "s3:prefix": "files*"
                }
            }
        },
        {
            "Sid": "ListMultipartRules",
            "Effect": "Allow",
            "Action": [
                "s3:ListBucketMultipartUploads",
                "s3:ListMultipartUploadParts"
            ],
            "Resource": [ "arn:aws:s3:::${var.name}", "arn:aws:s3:::${var.name}/*" ]
        },
        {
            "Sid": "GetBucketLoc",
            "Effect": "Allow",
            "Action": "s3:GetBucketLocation",
            "Resource": "arn:aws:s3:::${var.name}"
        },
        {
            "Sid": "WriteRules",
            "Effect": "Allow",
            "Action": [
                "s3:PutObject",
                "s3:AbortMultipartUpload",
                "s3:DeleteObject",
                "s3:GetObject"
            ],
            "Resource": "arn:aws:s3:::${var.name}/${var.s3folder}/*"
        }
    ]
  }
EOF
}

resource "aws_iam_role_policy" "apigateway_invoke" {
  name = "${var.name}_apigateway_invoke"
  role = aws_iam_role.cognito_authenticated.id

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "execute-api:Invoke",
                "execute-api:ManageConnections"
            ],
            "Resource": "arn:aws:execute-api:*:*:*"
        }
    ]
}
EOF
}

###
### LAMBDA "WEBSOCKET CLIPBOARD" 
###

resource "aws_iam_policy" "lambda_websocket" {
  name        = "${var.name}_lambda_websocket"
  path        = "/"
  description = "${var.name}_lambda_websocket"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": [
          "dynamodb:BatchGetItem",
          "dynamodb:GetItem",
          "dynamodb:Query",
          "dynamodb:Scan",
          "dynamodb:BatchWriteItem",
          "dynamodb:PutItem",
          "dynamodb:UpdateItem",
          "dynamodb:DeleteItem"
        ],
        "Resource": "arn:aws:dynamodb:${var.region}:${data.aws_caller_identity.current.account_id}:table/${module.dynamodb_table.dynamodb_table_id}"
      },
      {
        "Effect": "Allow",
        "Action": [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        "Resource": "arn:aws:logs:${var.region}:${data.aws_caller_identity.current.account_id}:*"
      },
      {
        "Effect": "Allow",
        "Action": "logs:CreateLogGroup",
        "Resource": "*"
      },
      {
        "Effect": "Allow",
        "Action": [
          "execute-api:Invoke"           
        ],
        "Resource": [
          "arn:aws:execute-api:${var.region}:${data.aws_caller_identity.current.account_id}:*"
        ]
      },
      {
        "Effect": "Allow",
        "Action": [
          "execute-api:ManageConnections"           
        ],
        "Resource": [
          "arn:aws:execute-api:${var.region}:${data.aws_caller_identity.current.account_id}:*"
        ]
      }      
    ]
}
EOF
}


# resource "aws_iam_role_policy_attachment" "roleattach2" {
#   role       = aws_iam_role.authenticated.name
#   policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
# }

###
### LAMBDA "CREATE ADMIN USER" IS USING A BUILT-IN POLICY COGNITOPOWERUSER, PROBABLY CAN BE LOCKED  DOWN FURTHER, BUT IT CANNOT BE INVOKED BY THI APP ONLY BY TERRAFORM
###

