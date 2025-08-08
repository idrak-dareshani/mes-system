# RDS Subnet Group
resource "aws_db_subnet_group" "mes_db_subnet_group" {
  name       = "mes-db-subnet-group"
  subnet_ids = [aws_subnet.mes_private_subnet_1.id, aws_subnet.mes_private_subnet_2.id]

  tags = {
    Name = "MES DB subnet group"
  }
}

# Security Group for RDS
resource "aws_security_group" "mes_rds_sg" {
  name_prefix = "mes-rds-sg"
  vpc_id      = aws_vpc.mes_vpc.id

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.mes_vpc.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "mes-rds-sg"
  }
}

# RDS PostgreSQL Instance
resource "aws_db_instance" "mes_postgres" {
  identifier     = "mes-postgres"
  engine         = "postgres"
  engine_version = "15.4"
  instance_class = "db.t3.micro"
  
  allocated_storage     = 20
  max_allocated_storage = 100
  storage_type          = "gp2"
  storage_encrypted     = true
  
  db_name  = "mes_db"
  username = var.db_username
  password = var.db_password
  
  vpc_security_group_ids = [aws_security_group.mes_rds_sg.id]
  db_subnet_group_name   = aws_db_subnet_group.mes_db_subnet_group.name
  
  backup_retention_period = 7
  backup_window          = "03:00-04:00"
  maintenance_window     = "sun:04:00-sun:05:00"
  
  skip_final_snapshot = true
  deletion_protection = false

  tags = {
    Name = "mes-postgres"
  }
}