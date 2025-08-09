# Application Load Balancer
resource "aws_lb" "mes_alb" {
  name               = "mes-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.mes_alb_sg.id]
  subnets            = [aws_subnet.mes_public_subnet_1.id, aws_subnet.mes_public_subnet_2.id]

  tags = {
    Name = "mes-alb"
  }
}

# ALB Security Group
resource "aws_security_group" "mes_alb_sg" {
  name_prefix = "mes-alb-sg"
  vpc_id      = aws_vpc.mes_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
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
    Name = "mes-alb-sg"
  }
}

# Target Groups
resource "aws_lb_target_group" "mes_backend_tg" {
  name        = "mes-backend-tg"
  port        = 8000
  protocol    = "HTTP"
  vpc_id      = aws_vpc.mes_vpc.id
  target_type = "ip"

  health_check {
    enabled             = true
    healthy_threshold   = 2
    interval            = 30
    matcher             = "200"
    path                = "/"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 5
    unhealthy_threshold = 2
  }
}

resource "aws_lb_target_group" "mes_frontend_tg" {
  name        = "mes-frontend-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.mes_vpc.id
  target_type = "ip"

  health_check {
    enabled             = true
    healthy_threshold   = 2
    interval            = 30
    matcher             = "200"
    path                = "/"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 5
    unhealthy_threshold = 2
  }
}

# ALB Listeners
resource "aws_lb_listener" "mes_backend_listener" {
  load_balancer_arn = aws_lb.mes_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.mes_frontend_tg.arn
  }
}

resource "aws_lb_listener_rule" "mes_backend_rule" {
  listener_arn = aws_lb_listener.mes_backend_listener.arn
  priority     = 100

  action {
    type = "forward"
    forward {
      target_group {
        arn = aws_lb_target_group.mes_backend_tg.arn
      }
    }
  }

  condition {
    path_pattern {
      values = ["/api/*"]
    }
  }
}

# Output ALB DNS
output "alb_dns_name" {
  value = aws_lb.mes_alb.dns_name
}