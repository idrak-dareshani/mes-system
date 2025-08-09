# ECR Repositories
resource "aws_ecr_repository" "mes_backend" {
  name                 = "mes-backend"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_repository" "mes_frontend" {
  name                 = "mes-frontend"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

# Output ECR URLs
output "backend_ecr_url" {
  value = aws_ecr_repository.mes_backend.repository_url
}

output "frontend_ecr_url" {
  value = aws_ecr_repository.mes_frontend.repository_url
}