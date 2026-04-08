terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    local = {
      version = "~> 2.1"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.0"
    }
  }

  required_version = ">= 1.2.0"
}


provider "aws" {
  region = var.region
  # version = "~> 2.3"
  
}

# Used as data.aws_caller_identity.current.account_id
data "aws_caller_identity" "current" {}


locals {
  aws_config = templatefile("${path.module}/templates/awsconfig.json", {
    region         = var.region
    bucket         = aws_s3_bucket.account.id
    userPoolId     = aws_cognito_user_pool.pool.id
    clientId       = aws_cognito_user_pool_client.client.id
    identityPoolId = aws_cognito_identity_pool.id_pool.id
    websocket_api  = aws_apigatewayv2_stage.stage_prod.invoke_url
    auth_proxy_url = "${trimsuffix(aws_apigatewayv2_stage.auth_proxy.invoke_url, "/")}/auth"
    auth_login_url = "https://${aws_cognito_user_pool_domain.main.domain}.auth.${var.region}.amazoncognito.com/login?response_type=token&client_id=${aws_cognito_user_pool_client.client.id}&redirect_uri=https://s3.amazonaws.com/${local.name}/index.html&scope=openid+profile+email"
  })
}
