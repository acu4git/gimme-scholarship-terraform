resource "random_password" "rds_admin_password" {
  length           = 16
  special          = true
  override_special = "!#$%&*"
}

resource "aws_secretsmanager_secret" "rds-master-password" {
  name        = "rds/gimme-scholarship/master-password"
  description = "MySQL master password for gimme-scholarship database"
}

resource "aws_secretsmanager_secret_version" "rds-master-password-version" {
  secret_id = aws_secretsmanager_secret.rds-master-password.id
  secret_string = jsonencode({
    username = "admin",
    password = random_password.rds_admin_password.result
  })
}
