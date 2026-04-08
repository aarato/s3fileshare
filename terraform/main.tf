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
    region        = var.region
    bucket        = aws_s3_bucket.account.id
    websocket_api = aws_apigatewayv2_stage.stage_prod.invoke_url
  })
}
