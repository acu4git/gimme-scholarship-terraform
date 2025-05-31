resource "aws_ssm_parameter" "clerk_jwks_url" {
  name  = "/${var.project}/clerk-jwks-url"
  type  = "String"
  value = var.clerk_jwks_url
}
