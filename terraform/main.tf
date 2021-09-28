provider "aws" {
  region = var.region
  # version = "~> 2.3"
}

data "aws_caller_identity" "current" {}

data "template_file" "aws_config" {
  template = file("./templates/awsconfig.json")

  vars = {
    region         = var.region
    bucket         = aws_s3_bucket.account.id
    userPoolId     = aws_cognito_user_pool.pool.id
    clientId       = aws_cognito_user_pool_client.client.id
    identityPoolId = aws_cognito_identity_pool.id_pool.id
    websocket_api  = aws_apigatewayv2_stage.stage_prod.invoke_url
  }
}

