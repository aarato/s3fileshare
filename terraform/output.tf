
output "login_url" {
  value = "https://s3.amazonaws.com/${local.name}/index.html"
}

output "login_access_key_id" {
  value = aws_iam_access_key.app_user.id
}

output "login_secret_access_key" {
  value = nonsensitive(aws_iam_access_key.app_user.secret)
}
