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
