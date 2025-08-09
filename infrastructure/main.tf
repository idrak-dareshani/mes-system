terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# VPC
resource "aws_vpc" "mes_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "mes-vpc"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "mes_igw" {
  vpc_id = aws_vpc.mes_vpc.id

  tags = {
    Name = "mes-igw"
  }
}

# Subnets
resource "aws_subnet" "mes_public_subnet_1" {
  vpc_id                  = aws_vpc.mes_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "${var.aws_region}a"
  map_public_ip_on_launch = true

  tags = {
    Name = "mes-public-subnet-1"
  }
}

resource "aws_subnet" "mes_public_subnet_2" {
  vpc_id                  = aws_vpc.mes_vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "${var.aws_region}b"
  map_public_ip_on_launch = true

  tags = {
    Name = "mes-public-subnet-2"
  }
}

resource "aws_subnet" "mes_private_subnet_1" {
  vpc_id            = aws_vpc.mes_vpc.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "${var.aws_region}a"

  tags = {
    Name = "mes-private-subnet-1"
  }
}

resource "aws_subnet" "mes_private_subnet_2" {
  vpc_id            = aws_vpc.mes_vpc.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = "${var.aws_region}b"

  tags = {
    Name = "mes-private-subnet-2"
  }
}

# Route Table
resource "aws_route_table" "mes_public_rt" {
  vpc_id = aws_vpc.mes_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.mes_igw.id
  }

  tags = {
    Name = "mes-public-rt"
  }
}

resource "aws_route_table_association" "mes_public_rta_1" {
  subnet_id      = aws_subnet.mes_public_subnet_1.id
  route_table_id = aws_route_table.mes_public_rt.id
}

resource "aws_route_table_association" "mes_public_rta_2" {
  subnet_id      = aws_subnet.mes_public_subnet_2.id
  route_table_id = aws_route_table.mes_public_rt.id
}

# NAT Gateway
resource "aws_eip" "mes_nat_eip" {
  domain = "vpc"
  
  tags = {
    Name = "mes-nat-eip"
  }
}

resource "aws_nat_gateway" "mes_nat_gw" {
  allocation_id = aws_eip.mes_nat_eip.id
  subnet_id     = aws_subnet.mes_public_subnet_1.id

  tags = {
    Name = "mes-nat-gw"
  }

  depends_on = [aws_internet_gateway.mes_igw]
}

# Private Route Table
resource "aws_route_table" "mes_private_rt" {
  vpc_id = aws_vpc.mes_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.mes_nat_gw.id
  }

  tags = {
    Name = "mes-private-rt"
  }
}

resource "aws_route_table_association" "mes_private_rta_1" {
  subnet_id      = aws_subnet.mes_private_subnet_1.id
  route_table_id = aws_route_table.mes_private_rt.id
}

resource "aws_route_table_association" "mes_private_rta_2" {
  subnet_id      = aws_subnet.mes_private_subnet_2.id
  route_table_id = aws_route_table.mes_private_rt.id
}