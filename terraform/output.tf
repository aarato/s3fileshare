
output "url" {
  value = "https://s3.${var.region}.amazonaws.com/${aws_s3_bucket.account.id}/index.html"
}

output "websocket_api" {
  value = aws_apigatewayv2_stage.stage_prod.invoke_url
}

# output "result_entry" {
#   value = jsondecode(data.aws_lambda_invocation.create_admin.result)
# }
