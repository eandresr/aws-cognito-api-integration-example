variable "domain" {
  type = string
}

variable "regional_wildcard_acm_arn" {
  type = string
}

variable "cloudfront_wildcard_acm_arn" {
  type = string
}

variable "cognito_callback_urls" {
  type = list(any)
}

variable "cloudfront_url" {
  type = string
}

variable "font_bucket_name" {
  type = string
}

variable "region" {
  type = string
}

variable "profile" {
  type    = string
  default = "default"
}
