
resource "aws_s3_bucket" "account" {
  bucket = var.name
  acl    = "private"
  force_destroy = true
  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET","PUT","DELETE","HEAD", "POST"]
    allowed_origins = ["*"]
    expose_headers  = ["ETag"]
    max_age_seconds = 3000
  }  
  lifecycle_rule {
    id      = "files"
    enabled = true
    prefix = "files/"
    expiration {
      days = 1
    }
  }
}

resource "aws_s3_object" "awsconfig" {
  bucket = aws_s3_bucket.account.id
  key    = "awsconfig.json"
  content = data.template_file.aws_config.rendered
  acl = "public-read"
  content_type = "text/json"
  # etag = filemd5(data.template_file.aws_config)
}

resource "aws_s3_object" "index" {
  bucket = aws_s3_bucket.account.id
  key    = "index.html"
  source = "../dist/index.html"
  acl = "public-read"
  content_type = "text/html"
  etag = filemd5("../dist/index.html")
}

resource "aws_s3_object" "favicon" {
  bucket = aws_s3_bucket.account.id
  key    = "favicon.ico"
  source = "../dist/favicon.ico"
  acl = "public-read"
  # content_type = "text/html"
  etag = filemd5("../dist/favicon.ico")
}

resource "aws_s3_object" "css" {
  for_each = fileset("../dist/css", "*")
  source = "../dist/css/${each.value}"
  acl = "public-read"
  content_type = "text/css"
  etag   = filemd5("../dist/css/${each.value}")
  bucket = aws_s3_bucket.account.id
  key    = "css/${each.value}"
}

resource "aws_s3_object" "js" {
  for_each = fileset("../dist/", "js/*")
  source = "../dist/${each.value}"
  acl = "public-read"
  content_type = "text/javascript"
  etag   = filemd5("../dist/${each.value}")
  bucket = aws_s3_bucket.account.id
  key    = each.value
}
