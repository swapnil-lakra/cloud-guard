resource "random_password" "grafana" {
  length  = 16
  special = false
}

resource "aws_secretsmanager_secret" "grafana_admin" {
  name        = "${var.project_name}-grafana-admin-pwd"
  description = "Grafana admin password for CloudGuard"
}

resource "aws_secretsmanager_secret_version" "grafana_admin" {
  secret_id     = aws_secretsmanager_secret.grafana_admin.id
  secret_string = random_password.grafana.result
}