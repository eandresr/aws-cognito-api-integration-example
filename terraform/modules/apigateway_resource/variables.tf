variable "api" {
  description = "id of an aws_api_gateway_rest_api resource"
}

variable "api_arn" {
  description = "ARN of an aws_api_gateway_rest_api resource"
}

variable "api_name" {
  description = "Name of an aws_api_gateway_rest_api resource"
}

variable "parent_id" {
  description = "parent_id let empty if need"
  default = ""
}

variable "authorization" {
  description = "COGNITO_USER_POOLS/NONE"
  default = "NONE"
}
variable "authorizer_id" {
  description = "AUTHORIZER ID"
  default = ""
}
variable "authorizer_scopes" {
  description = "AUTHORIZATINO SCOPES from cognito to allow certain scopes"
  default = []
}

variable "querystring" {
  description = "QueryString parameter, declared like: method.request.querystring.some-query-param = true"
  default = {
    "method.request.header.Authentication" = true
  }
}
variable "path" {
  description = "Path, / or /blablabla/"
}
variable "method" {
  description = "GET/POST"
  default = "POST"
}
variable "integrationtype" {
  description = "MOCK or AWS"
  default = "MOCK"
}

variable "lambda_permission" {
  description = "If you need Lambda permissions or not"
  default = 1
}

variable "lambda_invoke_arn" {
  description = "arn:aws:apigateway:{region}:{subdomain.service|service}:{path|action}/{service_api}. region, subdomain and service are used to determine the right endpoint. e.g., arn:aws:apigateway:eu-west-1:lambda:path/2015-03-31/functions/arn:aws:lambda:eu-west-1:012345678901:function:my-func/invocations"
  default = ""
}
variable "lambda_arn" {
  description = "arn:aws:apigateway:{region}:{subdomain.service|service}:{path|action}/{service_api}. region, subdomain and service are used to determine the right endpoint. e.g., arn:aws:apigateway:eu-west-1:lambda:path/2015-03-31/functions/arn:aws:lambda:eu-west-1:012345678901:function:my-func/invocations"
  default = ""
}
variable "methods" {
  type        = list(string)
  description = "List of permitted HTTP methods. OPTIONS is added by default."
}

variable "origin" {
  description = "Permitted origin"
  default     = "*"
}

variable "headers" {
  description = "List of permitted headers. Default headers are alway present unless discard_default_headers variable is set to true"
  default     = ["Content-Type", "X-Amz-Date", "Authentication", "Authorization", "X-Api-Key", "X-Amz-Security-Token", "Access-Control-Allow-Headers"]
}

variable "discard_default_headers" {
  default     = false
  description = "When set to true to it discards the default permitted headers and only includes those explicitly defined"
}

locals {
  methodOptions  = "OPTIONS"
  defaultHeaders = ["Content-Type", "X-Amz-Date", "Authentication", "Authorization", "X-Api-Key", "X-Amz-Security-Token", "Access-Control-Allow-Headers"]

  methods = join(",", distinct(concat(var.methods, [local.methodOptions])))
  headers = var.discard_default_headers ? join(",", var.headers) : join(",", distinct(concat(var.headers, local.defaultHeaders)))

  parent_id = var.parent_id != "" ? var.parent_id : data.aws_api_gateway_rest_api.api.root_resource_id
}

data "aws_api_gateway_rest_api" "api" {
  name = var.api_name
}