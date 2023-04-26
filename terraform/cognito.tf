resource "aws_cognito_user_pool" "pool" {
  name = local.name
  auto_verified_attributes = ["email"]

  password_policy {
    minimum_length = 8
    require_lowercase = false
    require_uppercase = false
    require_numbers = false
    require_symbols = false
  }

  lambda_config {
    post_authentication = aws_lambda_function.cognito_deactivate_guest.arn
  }

}

resource "aws_cognito_user_group" "admin" {
  name         = "admin"
  user_pool_id = aws_cognito_user_pool.pool.id
}

resource "aws_cognito_user_pool_client" "client" {
  name = local.name
  user_pool_id = aws_cognito_user_pool.pool.id
  explicit_auth_flows = ["ALLOW_CUSTOM_AUTH","ALLOW_USER_SRP_AUTH","ALLOW_ADMIN_USER_PASSWORD_AUTH","ALLOW_USER_PASSWORD_AUTH","ALLOW_USER_PASSWORD_AUTH","ALLOW_REFRESH_TOKEN_AUTH"]
}   


resource "aws_cognito_identity_pool" "id_pool" {
  identity_pool_name               = local.name
  allow_unauthenticated_identities = false
  allow_classic_flow               = false

  cognito_identity_providers {
    client_id               = aws_cognito_user_pool_client.client.id
    provider_name           = aws_cognito_user_pool.pool.endpoint   # "cognito-idp.us-east-1.amazonaws.com/us-east-1_Tv0493apJ"
    server_side_token_check = false
  }
}

resource "aws_cognito_identity_pool_roles_attachment" "roleattach1" {
  identity_pool_id = aws_cognito_identity_pool.id_pool.id
  roles = {
    "authenticated" = aws_iam_role.cognito_authenticated.arn
  }
}
