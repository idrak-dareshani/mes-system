# ECS Cluster
resource "aws_ecs_cluster" "mes_cluster" {
  name = "mes-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = {
    Name = "mes-cluster"
  }
}

# Security Group for ECS
resource "aws_security_group" "mes_ecs_sg" {
  name_prefix = "mes-ecs-sg"
  vpc_id      = aws_vpc.mes_vpc.id

  ingress {
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "mes-ecs-sg"
  }
}

# ECS Task Definition for Backend
resource "aws_ecs_task_definition" "mes_backend" {
  family                   = "mes-backend"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_execution_role.arn

  container_definitions = jsonencode([
    {
      name  = "mes-backend"
      image = "mes-backend:latest"
      portMappings = [
        {
          containerPort = 8000
          protocol      = "tcp"
        }
      ]
      environment = [
        {
          name  = "DATABASE_URL"
          value = "postgresql://${var.db_username}:${var.db_password}@${aws_db_instance.mes_postgres.endpoint}/mes_db"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.mes_backend.name
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "ecs"
        }
      }
    }
  ])
}

# ECS Service for Backend
resource "aws_ecs_service" "mes_backend_service" {
  name            = "mes-backend-service"
  cluster         = aws_ecs_cluster.mes_cluster.id
  task_definition = aws_ecs_task_definition.mes_backend.arn
  desired_count   = 2
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = [aws_subnet.mes_public_subnet_1.id, aws_subnet.mes_public_subnet_2.id]
    security_groups = [aws_security_group.mes_ecs_sg.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.mes_backend_tg.arn
    container_name   = "mes-backend"
    container_port   = 8000
  }

  depends_on = [aws_lb_listener.mes_backend_listener]
}