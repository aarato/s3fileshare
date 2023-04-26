resource "aws_s3_bucket" "account" {
  bucket = local.name
  force_destroy = true

}

resource "aws_s3_bucket_public_access_block" "account" {
  bucket = aws_s3_bucket.account.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_ownership_controls" "account" {
  bucket = aws_s3_bucket.account.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "account" {
  depends_on = [	aws_s3_bucket_public_access_block.account,	aws_s3_bucket_ownership_controls.account ]
  bucket = aws_s3_bucket.account.id
  acl    = "public-read"
}


resource "aws_s3_bucket_policy" "account" {
  bucket = aws_s3_bucket.account.id
  policy = jsonencode({
      "Version": "2012-10-17",
      "Id": "PublicWebPage",
      "Statement": [
        {
        "Sid": "DenyObjectsThatAreNotSSEKMS",
        "Principal": "*",
        "Effect": "Allow",
        "Action": [ 
          "s3:GetObject"
          ],
        "Resource":[ 
          "${aws_s3_bucket.account.arn}/index.html",
          "${aws_s3_bucket.account.arn}/favicon.ico",
          "${aws_s3_bucket.account.arn}/awsconfig.json",
          "${aws_s3_bucket.account.arn}/assets/*",
          ]
        }
      ]
  })
  depends_on = [
    aws_s3_object.index,
    aws_s3_object.favicon,
    aws_s3_object.awsconfig,
    aws_s3_object.css,
  ]
}


resource "aws_s3_bucket_lifecycle_configuration" "this" {
  bucket = local.name
  rule {
    id      = "files"
    filter {
      prefix = "files/"
    }    
    expiration {
      days = 1
    }
    status = "Enabled"
  }
}

resource "aws_s3_bucket_cors_configuration" "this" {
  bucket = local.name

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET","PUT","DELETE","HEAD", "POST"]
    allowed_origins = ["*"] // allowed_origins = ["https://s3-website-test.hashicorp.com"]
    expose_headers  = ["ETag"]
    max_age_seconds = 3000
  }
}

resource "aws_s3_object" "awsconfig" {
  bucket = aws_s3_bucket.account.id
  key    = "awsconfig.json"
  content = data.template_file.aws_config.rendered
  content_type = "text/json"
  # etag = filemd5(data.template_file.aws_config)
}

resource "aws_s3_object" "index" {
  bucket = aws_s3_bucket.account.id
  key    = "index.html"
  source = "../dist/index.html"
  content_type = "text/html"
  etag = filemd5("../dist/index.html")
}

resource "aws_s3_object" "favicon" {
  bucket = aws_s3_bucket.account.id
  key    = "favicon.ico"
  source = "../dist/favicon.ico"
  # content_type = "text/html"
  etag = filemd5("../dist/favicon.ico")
}

resource "aws_s3_object" "css" {
  for_each = fileset("../dist/assets", "*.css")
  source = "../dist/assets/${each.value}"
  content_type = "text/css"
  etag   = filemd5("../dist/assets/${each.value}")
  bucket = aws_s3_bucket.account.id
  key    = "assets/${each.value}"
}

resource "aws_s3_object" "js" {
  for_each = fileset("../dist/assets", "*.js")
  source = "../dist/assets/${each.value}"
  content_type = "text/javascript"
  etag   = filemd5("../dist/assets/${each.value}")
  bucket = aws_s3_bucket.account.id
  key    = "assets/${each.value}"
}

resource "aws_s3_object" "woff" {
  for_each = fileset("../dist/assets", "*.woff")
  source = "../dist/assets/${each.value}"
  content_type = "font/woff"
  etag   = filemd5("../dist/assets/${each.value}")
  bucket = aws_s3_bucket.account.id
  key    = "assets/${each.value}"
}

resource "aws_s3_object" "woff2" {
  for_each = fileset("../dist/assets", "*.woff2")
  source = "../dist/assets/${each.value}"
  content_type = "font/woff2"
  etag   = filemd5("../dist/assets/${each.value}")
  bucket = aws_s3_bucket.account.id
  key    = "assets/${each.value}"
}
