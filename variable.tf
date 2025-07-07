variable "domain_name" {
  type = string
}

variable "account_id" {
  type = string
}

variable "project" {
  type    = string
  default = "gimme-scholarship"
}

variable "default_profile" {
  type    = string
  default = "acu-admin"
}

variable "default_region" {
  type    = string
  default = "ap-northeast-1"
}

variable "default_tags" {
  type = map(string)

  default = {
    Project   = "gimme-scholarship"
    ManagedBy = "https://github.com/acu4git/gimme-scholarship-terraform"
  }
}

variable "db_name" {
  type = string
}

variable "clerk_jwks_url" {
  type = string
}

variable "clerk_webhook_secret" {
  type = string
}

variable "cloudflare_api_token" {
  type = string
}

variable "cloudflare_zone_id" {
  type = string
}
