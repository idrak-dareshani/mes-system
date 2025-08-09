# ElastiCache Subnet Group
resource "aws_elasticache_subnet_group" "mes_redis_subnet_group" {
  name       = "mes-redis-subnet-group"
  subnet_ids = [aws_subnet.mes_private_subnet_1.id, aws_subnet.mes_private_subnet_2.id]
}

# Security Group for ElastiCache
resource "aws_security_group" "mes_redis_sg" {
  name_prefix = "mes-redis-sg"
  vpc_id      = aws_vpc.mes_vpc.id

  ingress {
    from_port   = 6379
    to_port     = 6379
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
    Name = "mes-redis-sg"
  }
}

# ElastiCache Redis Cluster
resource "aws_elasticache_replication_group" "mes_redis" {
  replication_group_id       = "mes-redis"
  description                = "Redis cluster for MES system"
  
  node_type                  = "cache.t3.micro"
  port                       = 6379
  parameter_group_name       = "default.redis7"
  
  num_cache_clusters         = 1
  
  subnet_group_name          = aws_elasticache_subnet_group.mes_redis_subnet_group.name
  security_group_ids         = [aws_security_group.mes_redis_sg.id]
  
  at_rest_encryption_enabled = true
  transit_encryption_enabled = false
  
  tags = {
    Name = "mes-redis"
  }
}

# Output Redis endpoint
output "redis_endpoint" {
  value = aws_elasticache_replication_group.mes_redis.primary_endpoint_address
}