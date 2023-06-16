resource "aws_iam_role" "example" {
  name = "lambda_role_from_apigateway_example"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_api_gateway_rest_api" "example" {
  name = "example_apigateway"
  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_authorizer" "example" {
  name                   = "example_cognito_user_pool"
  type                   = "COGNITO_USER_POOLS"
  rest_api_id            = aws_api_gateway_rest_api.example.id
  provider_arns          = [aws_cognito_user_pool.example.arn]
  authorizer_credentials = aws_iam_role.example.arn
  identity_source        = "method.request.header.Authentication"
}

resource "aws_api_gateway_deployment" "example" {
  rest_api_id = aws_api_gateway_rest_api.example.id
  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_rest_api.example.body
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "example" {
  deployment_id = aws_api_gateway_deployment.example.id
  rest_api_id   = aws_api_gateway_rest_api.example.id
  stage_name    = "v0"
}

module "example" {
  source            = "./modules/apigateway_resource"
  api               = aws_api_gateway_rest_api.example.id
  api_name          = aws_api_gateway_rest_api.example.name
  api_arn           = aws_api_gateway_rest_api.example.arn
  authorization     = "COGNITO_USER_POOLS"
  authorizer_id     = aws_api_gateway_authorizer.example.id
  authorizer_scopes = ["api/get"]
  methods           = ["GET"]
  path              = "auth-validation"
  method            = "GET"
  parent_id         = aws_api_gateway_rest_api.example.root_resource_id
  depends_on        = [aws_api_gateway_rest_api.example]
  querystring       = { "method.request.querystring.oname" = true, "method.request.querystring.otype" = false }
  integrationtype   = "AWS_PROXY"
  lambda_arn        = aws_lambda_function.example.arn
  lambda_invoke_arn = aws_lambda_function.example.invoke_arn
  lambda_permission = 1
}