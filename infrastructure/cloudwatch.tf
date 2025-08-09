# CloudWatch Log Groups
resource "aws_cloudwatch_log_group" "mes_backend" {
  name              = "/ecs/mes-backend"
  retention_in_days = 7

  tags = {
    Name = "mes-backend-logs"
  }
}

resource "aws_cloudwatch_log_group" "mes_frontend" {
  name              = "/ecs/mes-frontend"
  retention_in_days = 7

  tags = {
    Name = "mes-frontend-logs"
  }
}