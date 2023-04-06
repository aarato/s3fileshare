terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
    local = {
      version = "~> 2.1"
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

data "template_file" "aws_config" {
  template = file("./templates/awsconfig.json")

  vars = {
    region         = var.region
    bucket         = aws_s3_bucket.account.id
    userPoolId     = aws_cognito_user_pool.pool.id
    clientId       = aws_cognito_user_pool_client.client.id
    identityPoolId = aws_cognito_identity_pool.id_pool.id
    websocket_api  = "aws_apigatewayv2_stage.stage_prod.invoke_url"

  }
}

# data "template_file" "aws_config" {
#   template = file("./templates/awsconfig.json")

#   vars = {
#     region         = var.region
#     bucket         = aws_s3_bucket.account.id
#     userPoolId     = aws_cognito_user_pool.pool.id
#     clientId       = aws_cognito_user_pool_client.client.id
#     identityPoolId = aws_cognito_identity_pool.id_pool.id
#     websocket_api  = aws_apigatewayv2_stage.stage_prod.invoke_url
#   }
# }
