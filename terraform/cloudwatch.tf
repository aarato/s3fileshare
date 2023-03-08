###
### FOR LAMBDA
###
resource "aws_cloudwatch_log_group" "lambda_create_cognito_user" {
  name = "/aws/lambda/${var.name}_lambda_create_cognito_user"
  retention_in_days = 7
  tags = {
    Environment = "production"
    Application = "Terraform"
  }
}

###
###  FOR API GATEWAY
###
# resource "aws_cloudwatch_log_group" "stage_prod" {
#   name = "/aws/apigateway/${aws_apigatewayv2_api.clipboard.id}/prod"
#   retention_in_days = 7
#   tags = {
#     Environment = "production"
#     Application = "Terraform"
#   }
# }
