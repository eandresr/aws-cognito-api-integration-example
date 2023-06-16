data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

resource "aws_api_gateway_resource" "apigateway_resource" {
  parent_id   = var.parent_id
  path_part   = var.path
  rest_api_id = var.api
}
locals{
  lambdaSplit = split(":", var.lambda_arn) 
  lambdaName = element(local.lambdaSplit, length(local.lambdaSplit)-1)
}
resource "aws_lambda_permission" "allow_api" {
  count = var.lambda_permission
  statement_id  = "AllowAPIgatewayInvokation"
  action        = "lambda:InvokeFunction"
  function_name = local.lambdaName #var.lambda_arn
  principal     = "apigateway.amazonaws.com"
  source_arn = "arn:aws:execute-api:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:${var.api}/*/${aws_api_gateway_method.method.http_method}${aws_api_gateway_resource.apigateway_resource.path}"
}
resource "aws_api_gateway_method" "method" {
  rest_api_id   = var.api
  resource_id   = aws_api_gateway_resource.apigateway_resource.id
  http_method   = var.method
  authorization = var.authorization
  authorizer_id = var.authorization == "NONE" ? null : var.authorizer_id
  authorization_scopes = var.authorizer_scopes
  request_parameters = var.authorization == "NONE" ? var.querystring : merge({
    "method.request.header.Authentication" = true
  }, var.querystring)
}

resource "aws_api_gateway_method_response" "method_response" {
  rest_api_id = var.api
  resource_id = aws_api_gateway_resource.apigateway_resource.id
  http_method = aws_api_gateway_method.method.http_method

  status_code = "200"



  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Origin" = true
  }
}
resource "aws_api_gateway_integration" "integration" {
  depends_on = [aws_api_gateway_method.method]
  rest_api_id = var.api
  resource_id = aws_api_gateway_resource.apigateway_resource.id
  http_method = aws_api_gateway_method.method.http_method
  content_handling = "CONVERT_TO_TEXT"
  request_parameters      = {}
  type        = "AWS"
  uri = var.lambda_invoke_arn
  integration_http_method     = "POST"
  request_templates = {
    "application/json" = <<EOF
##  See http://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-mapping-template-reference.html
##  This template will pass through all parameters including path, querystring, header, stage variables, and context through to the integration endpoint via the body/payload
#set($allParams = $input.params())
{
"body-json" : $input.json('$'),
"params" : {
#foreach($type in $allParams.keySet())
    #set($params = $allParams.get($type))
"$type" : {
    #foreach($paramName in $params.keySet())
    "$paramName" : "$util.escapeJavaScript($params.get($paramName))"
        #if($foreach.hasNext),#end
    #end
}
    #if($foreach.hasNext),#end
#end
},
"stage-variables" : {
#foreach($key in $stageVariables.keySet())
"$key" : "$util.escapeJavaScript($stageVariables.get($key))"
    #if($foreach.hasNext),#end
#end
},
"context" : {
    "account-id" : "$context.identity.accountId",
    "api-id" : "$context.apiId",
    "api-key" : "$context.identity.apiKey",
    "authorizer-principal-id" : "$context.authorizer.principalId",
    "caller" : "$context.identity.caller",
    "cognito-authentication-provider" : "$context.identity.cognitoAuthenticationProvider",
    "cognito-authentication-type" : "$context.identity.cognitoAuthenticationType",
    "cognito-identity-id" : "$context.identity.cognitoIdentityId",
    "cognito-identity-pool-id" : "$context.identity.cognitoIdentityPoolId",
    "http-method" : "$context.httpMethod",
    "stage" : "$context.stage",
    "source-ip" : "$context.identity.sourceIp",
    "user" : "$context.identity.user",
    "user-agent" : "$context.identity.userAgent",
    "user-arn" : "$context.identity.userArn",
    "request-id" : "$context.requestId",
    "resource-id" : "$context.resourceId",
    "resource-path" : "$context.resourcePath"
    }
}
EOF
  }
}

resource "aws_api_gateway_integration_response" "integration_response" {
  rest_api_id = var.api
  resource_id = aws_api_gateway_method.method.resource_id
  http_method = aws_api_gateway_method.method.http_method

  status_code = aws_api_gateway_method_response.method_response.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'${local.headers}'"
    "method.response.header.Access-Control-Allow-Methods" = "'${local.methods}'"
    "method.response.header.Access-Control-Allow-Origin" = "'${var.origin}'"
  }
}