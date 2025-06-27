terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }

    cloudflare = {
      source = "cloudflare/cloudflare"
      version = "~> 4.0"
    }
  }

  required_version = ">= 1.3.0"
}

provider "aws" {
  region  = var.default_region
  profile = var.default_profile

  default_tags {
    tags = var.default_tags
  }
}

provider "cloudflare" {
  api_token = var.cloudflare_api_token
}