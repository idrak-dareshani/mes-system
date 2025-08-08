# MES (Manufacturing Execution System)

A modern Manufacturing Execution System built with FastAPI, React, and deployed on AWS.

## Features

- **Production Order Management**: Create, track, and manage production orders
- **Work Station Monitoring**: Real-time status of manufacturing workstations
- **Quality Control**: Track quality parameters and compliance
- **Real-time Dashboard**: Live metrics and production analytics
- **AWS Cloud Deployment**: Scalable infrastructure on AWS

## Architecture

- **Backend**: FastAPI (Python) with PostgreSQL database
- **Frontend**: React.js with Material-UI
- **Message Queue**: Redis for real-time updates
- **Infrastructure**: AWS ECS, RDS, ElastiCache, ALB
- **Monitoring**: CloudWatch for logging and metrics

## Local Development

1. **Prerequisites**:
   - Docker and Docker Compose
   - Python 3.11+
   - Node.js 18+

2. **Start the application**:
   ```bash
   docker-compose up -d
   ```

3. **Access the application**:
   - Frontend: http://localhost:3000
   - Backend API: http://localhost:8000
   - API Documentation: http://localhost:8000/docs

## AWS Deployment

1. **Configure AWS credentials**:
   ```bash
   aws configure
   ```

2. **Deploy infrastructure**:
   ```bash
   cd infrastructure
   terraform init
   terraform plan
   terraform apply
   ```

3. **Build and push Docker images**:
   ```bash
   # Build images
   docker build -f docker/Dockerfile.backend -t mes-backend .
   docker build -f docker/Dockerfile.frontend -t mes-frontend .
   
   # Tag and push to ECR
   aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin <account-id>.dkr.ecr.us-east-1.amazonaws.com
   docker tag mes-backend:latest <account-id>.dkr.ecr.us-east-1.amazonaws.com/mes-backend:latest
   docker push <account-id>.dkr.ecr.us-east-1.amazonaws.com/mes-backend:latest
   ```

## API Endpoints

- `GET /` - Health check
- `POST /production-orders/` - Create production order
- `GET /production-orders/` - List production orders
- `POST /workstations/` - Create workstation
- `GET /workstations/` - List workstations
- `POST /quality-checks/` - Create quality check

## Environment Variables

- `DATABASE_URL` - PostgreSQL connection string
- `REDIS_URL` - Redis connection string
- `AWS_REGION` - AWS region for deployment

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request