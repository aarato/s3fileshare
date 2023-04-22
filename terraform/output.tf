
output "url" {
  value = "https://${aws_s3_bucket.account.id}.s3.${var.region}.amazonaws.com/index.html"
}

output "password" {
  value = local.password
}

output "aws_s3_bucket" {
  value = local.name
}

output "websocket_api" {
  value = aws_apigatewayv2_stage.stage_prod.invoke_url
}

