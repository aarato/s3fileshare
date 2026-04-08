
output "login" {
  value = <<-EOT

    URL:               https://s3.amazonaws.com/${local.name}/index.html
    Access Key ID:     ${aws_iam_access_key.app_user.id}
    Secret Access Key: ${aws_iam_access_key.app_user.secret}
  EOT
  sensitive = true
}

output "app_user_access_key_id" {
  value = aws_iam_access_key.app_user.id
}

output "app_user_secret_access_key" {
  value = nonsensitive(aws_iam_access_key.app_user.secret)
}

output "url" {
  value = "https://${aws_s3_bucket.account.id}.s3.${var.region}.amazonaws.com/index.html"
}

output "password" {
  value = nonsensitive(local.password)
  #  sensitive = true
}

output "aws_s3_bucket" {
  value = local.name
}

output "websocket_api" {
  value = aws_apigatewayv2_stage.stage_prod.invoke_url
}

output "aws_cognito_user_pool_id" {
  value = aws_cognito_user_pool.pool.id
}

output "aws_s3_bucket_arn" {
  value = aws_s3_bucket.account.arn
}

output "auth_proxy_url" {
  value = "${trimsuffix(aws_apigatewayv2_stage.auth_proxy.invoke_url, "/")}/auth"
}

output "auth_login_url" {
  value = "https://${aws_cognito_user_pool_domain.main.domain}.auth.${var.region}.amazoncognito.com/login?response_type=token&client_id=${aws_cognito_user_pool_client.client.id}&redirect_uri=https://s3.amazonaws.com/${local.name}/index.html&scope=openid+profile+email"
}
