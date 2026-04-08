###
### IAM USER FOR APP LOGIN
### Scoped to: S3 files folder + WebSocket API invoke
###

resource "aws_iam_user" "app_user" {
  name = "${local.name}_app_user"
}

resource "aws_iam_user_policy" "app_user_s3" {
  name = "${local.name}_app_user_s3"
  user = aws_iam_user.app_user.name

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
            "Resource": "arn:aws:s3:::${local.name}",
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
            "Resource": [ "arn:aws:s3:::${local.name}", "arn:aws:s3:::${local.name}/*" ]
        },
        {
            "Sid": "GetBucketLoc",
            "Effect": "Allow",
            "Action": "s3:GetBucketLocation",
            "Resource": "arn:aws:s3:::${local.name}"
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
            "Resource": "arn:aws:s3:::${local.name}/${var.s3folder}/*"
        },
        {
            "Sid": "WebSocketInvoke",
            "Effect": "Allow",
            "Action": [
                "execute-api:Invoke",
                "execute-api:ManageConnections"
            ],
            "Resource": "${aws_apigatewayv2_api.clipboard.execution_arn}/*"
        }
    ]
}
EOF
}

resource "aws_iam_access_key" "app_user" {
  user = aws_iam_user.app_user.name
}
