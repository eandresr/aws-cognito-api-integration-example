locals {
  cognito_domain = "auth.${var.domain}"
  apigw_domain   = "api.${var.domain}"
  front_domain   = "www1.${var.domain}"
}