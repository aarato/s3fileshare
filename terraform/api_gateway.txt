###
### API GATEWAY
###
resource "aws_apigatewayv2_api" "clipboard" {
  name                       = "${var.name}_clipboard"
  protocol_type              = "WEBSOCKET"
  route_selection_expression = "$request.body.action"

}


# ROLE FOR API Gateway Account. Settings is applied region-wide per provider block.
resource "aws_api_gateway_account" "demo" {
  cloudwatch_role_arn = aws_iam_role.cloudwatch.arn
}

# ROUTES
resource "aws_apigatewayv2_route" "clipboard_connect" {
  api_id    = aws_apigatewayv2_api.clipboard.id
  route_key = "$connect"
  authorization_type = "AWS_IAM"
  target = "integrations/${aws_apigatewayv2_integration.clipboard_connect.id}"
}
resource "aws_apigatewayv2_route" "clipboard_disconnect" {
  api_id    = aws_apigatewayv2_api.clipboard.id
  route_key = "$disconnect"
  target = "integrations/${aws_apigatewayv2_integration.clipboard_disconnect.id}"
}
resource "aws_apigatewayv2_route" "clipboard_sendmessage" {
  api_id    = aws_apigatewayv2_api.clipboard.id
  route_key = "$default"
  target = "integrations/${aws_apigatewayv2_integration.clipboard_sendmessage.id}"
}

# INTEGRATIONS
resource "aws_apigatewayv2_integration" "clipboard_connect" {
  api_id           = aws_apigatewayv2_api.clipboard.id
  integration_type = "AWS_PROXY"

  connection_type           = "INTERNET"
  content_handling_strategy = "CONVERT_TO_TEXT"
  description               = "clipboard_connect"
  integration_method        = "POST"
  integration_uri           = module.lambda_clipboard_onconnect.lambda_function_invoke_arn
  passthrough_behavior      = "WHEN_NO_MATCH"
}
resource "aws_apigatewayv2_integration" "clipboard_disconnect" {
  api_id           = aws_apigatewayv2_api.clipboard.id
  integration_type = "AWS_PROXY"

  connection_type           = "INTERNET"
  content_handling_strategy = "CONVERT_TO_TEXT"
  description               = "clipboard_disconnect"
  integration_method        = "POST"
  integration_uri           = module.lambda_clipboard_disconnect.lambda_function_invoke_arn
  passthrough_behavior      = "WHEN_NO_MATCH"
}
resource "aws_apigatewayv2_integration" "clipboard_sendmessage" {
  api_id           = aws_apigatewayv2_api.clipboard.id
  integration_type = "AWS_PROXY"

  connection_type           = "INTERNET"
  content_handling_strategy = "CONVERT_TO_TEXT"
  description               = "clipboard_sendmessage"
  integration_method        = "POST"
  integration_uri           = module.lambda_clipboard_sendmessage.lambda_function_invoke_arn
  passthrough_behavior      = "WHEN_NO_MATCH"
}

# DEPLOYMENT
resource "aws_apigatewayv2_deployment" "clipboard" {
  api_id      = aws_apigatewayv2_api.clipboard.id
  description = "clipboard deployment"

  triggers = {
    redeployment = sha1(join(",", tolist(
      [
      jsonencode(aws_apigatewayv2_integration.clipboard_connect),
      jsonencode(aws_apigatewayv2_route.clipboard_connect),
      jsonencode(aws_apigatewayv2_integration.clipboard_disconnect),
      jsonencode(aws_apigatewayv2_route.clipboard_disconnect),
      jsonencode(aws_apigatewayv2_integration.clipboard_sendmessage),
      jsonencode(aws_apigatewayv2_route.clipboard_sendmessage),
      ]
    )))
  }
  lifecycle {
    create_before_destroy = true
  }
  depends_on = [
    aws_apigatewayv2_integration.clipboard_connect,
    aws_apigatewayv2_integration.clipboard_disconnect,
    aws_apigatewayv2_integration.clipboard_sendmessage,
  ]
}

# STAGE - PROD
resource "aws_apigatewayv2_stage" "stage_prod" {
  api_id = aws_apigatewayv2_api.clipboard.id
  deployment_id = aws_apigatewayv2_deployment.clipboard.id
  name   = "prod"
  default_route_settings {
    throttling_rate_limit = 100
    throttling_burst_limit = 50
    data_trace_enabled = true
    logging_level = "INFO"
  }
  route_settings {
    route_key = "$connect"
    throttling_rate_limit = 100
    throttling_burst_limit = 50
    data_trace_enabled = true
    logging_level = "INFO"
  }
  depends_on = [aws_cloudwatch_log_group.stage_prod]
}



# This API GATEWAY AUTHORIZER IS NOT GOOD FOR WEBSOCKETS BUT STILL A GOOD SNIP FOR HTTP.
# resource "aws_apigatewayv2_authorizer" "example" {
#   name                   = "${var.name}_api_authorizer"
#   api_id           = aws_apigatewayv2_api.clipboard.id
#   authorizer_type  = "REQUEST"  # This is the only supported type for websocket API
#   identity_sources = ["$request.header.Authorization"]

#   jwt_configuration {
#     audience = [aws_cognito_user_pool_client.client.id] # This needs to be the app client id! Duh!
#     issuer   = "https://${aws_cognito_user_pool.pool.endpoint}"
#   }
# }
