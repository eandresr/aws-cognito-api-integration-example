# resource "aws_api_gateway_domain_name" "example" {
#   domain_name              = local.apigw_domain
#   regional_certificate_arn = var.regional_wildcard_acm_arn

#   endpoint_configuration {
#     types = ["REGIONAL"]
#   }
# }

# resource "aws_api_gateway_base_path_mapping" "mapping" {
#   api_id      = aws_api_gateway_rest_api.example_apigateway.id
#   stage_name  = aws_api_gateway_stage.stage.stage_name
#   domain_name = aws_api_gateway_domain_name.example.domain_name
# }

# resource "aws_route53_record" "example_apigateway" {
#   name    = "api.${var.domain}"
#   type    = "A"
#   zone_id = data.aws_route53_zone.example.zone_id

#   alias {
#     evaluate_target_health = true
#     name                   = aws_api_gateway_domain_name.example.regional_domain_name
#     zone_id                = aws_api_gateway_domain_name.example.regional_zone_id
#   }
# }

# resource "aws_cognito_user_pool_domain" "main" {
#   domain          = local.cognito_domain
#   user_pool_id    = aws_cognito_user_pool.pool.id
#   certificate_arn = var.cloudfront_wildcard_acm_arn
# }


data "aws_route53_zone" "example" {
  name         = var.domain
  private_zone = false
}

resource "aws_route53_record" "example" {
  allow_overwrite = true
  name            = local.front_domain
  records         = [aws_cloudfront_distribution.example.domain_name]
  ttl             = 60
  type            = "CNAME"
  zone_id         = data.aws_route53_zone.example.zone_id
}


# resource "aws_route53_record" "cognito" {
#   name    = aws_cognito_user_pool_domain.main.domain
#   type    = "A"
#   zone_id = data.aws_route53_zone.example.zone_id
#   alias {
#     evaluate_target_health = false

#     name    = aws_cognito_user_pool_domain.main.cloudfront_distribution
#     zone_id = aws_cognito_user_pool_domain.main.cloudfront_distribution_zone_id
#   }
# }