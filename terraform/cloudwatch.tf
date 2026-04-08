###
###  FOR API GATEWAY
###
resource "aws_cloudwatch_log_group" "stage_prod" {
  name = "/aws/apigateway/${aws_apigatewayv2_api.clipboard.id}/prod"
  retention_in_days = 7
  tags = {
    Environment = "production"
    Application = "Terraform"
  }
}
