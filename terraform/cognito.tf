resource "aws_cognito_user_pool" "example" {
  name = "example_cognito_user_pool"

  schema {
    attribute_data_type      = "String"
    developer_only_attribute = false
    mutable                  = true
    name                     = "groups"
    required                 = false

    string_attribute_constraints {
      max_length = "256"
      min_length = "1"
    }
  }

  account_recovery_setting {
    recovery_mechanism {
      name     = "admin_only"
      priority = 1
    }
  }

}

resource "aws_cognito_user_pool_domain" "example" {
  domain       = "a-example"
  user_pool_id = aws_cognito_user_pool.example.id
}

resource "aws_cognito_user_pool_ui_customization" "user_pool_ui_customization" {
  user_pool_id = aws_cognito_user_pool.example.id
  image_file   = filebase64("include/sec.png")
}

resource "aws_cognito_user_pool_client" "example" {
  name = "example-client"

  #List of allowed callback URLs for the identity providers.
  callback_urls   = var.cognito_callback_urls
  user_pool_id    = aws_cognito_user_pool.example.id
  generate_secret = true

  supported_identity_providers = ["COGNITO"]

  explicit_auth_flows = [
    "ALLOW_CUSTOM_AUTH",
    "ALLOW_REFRESH_TOKEN_AUTH",
    "ALLOW_USER_SRP_AUTH",
  ]

  allowed_oauth_flows = [
    "implicit"
  ]

  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_scopes = [
    "aws.cognito.signin.user.admin"
  ]
}

resource "aws_cognito_identity_pool" "example" {
  identity_pool_name               = "example-identity-pool"
  allow_unauthenticated_identities = false

  cognito_identity_providers {
    client_id               = aws_cognito_user_pool_client.example.id
    provider_name           = aws_cognito_user_pool.example.endpoint
    server_side_token_check = false
  }
}

resource "aws_cognito_resource_server" "example" {
  identifier = "api"
  name       = "api"

  scope {
    scope_name        = "get"
    scope_description = "Sample GET Scope Description"
  }

  user_pool_id = aws_cognito_user_pool.example.id
}