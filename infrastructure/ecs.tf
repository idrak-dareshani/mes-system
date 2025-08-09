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
    from_port       = 8000
    to_port         = 8000
    protocol        = "tcp"
    security_groups = [aws_security_group.mes_alb_sg.id]
  }

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.mes_alb_sg.id]
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
  task_role_arn           = aws_iam_role.ecs_task_role.arn

  container_definitions = jsonencode([
    {
      name  = "mes-backend"
      image = "${aws_ecr_repository.mes_backend.repository_url}:latest"
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
        },
        {
          name  = "REDIS_URL"
          value = "redis://${aws_elasticache_replication_group.mes_redis.primary_endpoint_address}:6379"
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
    subnets         = [aws_subnet.mes_private_subnet_1.id, aws_subnet.mes_private_subnet_2.id]
    security_groups = [aws_security_group.mes_ecs_sg.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.mes_backend_tg.arn
    container_name   = "mes-backend"
    container_port   = 8000
  }

  depends_on = [aws_lb_listener.mes_backend_listener]
}

# ECS Task Definition for Frontend
resource "aws_ecs_task_definition" "mes_frontend" {
  family                   = "mes-frontend"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_execution_role.arn
  task_role_arn           = aws_iam_role.ecs_task_role.arn

  container_definitions = jsonencode([
    {
      name  = "mes-frontend"
      image = "${aws_ecr_repository.mes_frontend.repository_url}:latest"
      portMappings = [
        {
          containerPort = 80
          protocol      = "tcp"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.mes_frontend.name
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "ecs"
        }
      }
    }
  ])
}

# ECS Service for Frontend
resource "aws_ecs_service" "mes_frontend_service" {
  name            = "mes-frontend-service"
  cluster         = aws_ecs_cluster.mes_cluster.id
  task_definition = aws_ecs_task_definition.mes_frontend.arn
  desired_count   = 2
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = [aws_subnet.mes_private_subnet_1.id, aws_subnet.mes_private_subnet_2.id]
    security_groups = [aws_security_group.mes_ecs_sg.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.mes_frontend_tg.arn
    container_name   = "mes-frontend"
    container_port   = 80
  }

  depends_on = [aws_lb_listener.mes_backend_listener]
}