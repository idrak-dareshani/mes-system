#!/bin/bash

# MES System Deployment Script
set -e

# Configuration
AWS_REGION="us-east-1"
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)

echo "Starting MES deployment..."
echo "AWS Account ID: $AWS_ACCOUNT_ID"
echo "AWS Region: $AWS_REGION"

# Step 1: Deploy infrastructure
echo "Deploying infrastructure..."
cd infrastructure
terraform init
terraform plan -var="db_password=YourSecurePassword123!"
terraform apply -var="db_password=YourSecurePassword123!" -auto-approve

# Get ECR repository URLs
BACKEND_ECR_URL=$(terraform output -raw backend_ecr_url)
FRONTEND_ECR_URL=$(terraform output -raw frontend_ecr_url)

echo "Backend ECR URL: $BACKEND_ECR_URL"
echo "Frontend ECR URL: $FRONTEND_ECR_URL"

cd ..

# Step 2: Build and push Docker images
echo "Building and pushing Docker images..."

# Login to ECR
aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com

# Build and push backend
echo "Building backend image..."
docker build -f docker/Dockerfile.backend -t mes-backend .
docker tag mes-backend:latest $BACKEND_ECR_URL:latest
docker push $BACKEND_ECR_URL:latest

# Build and push frontend
echo "Building frontend image..."
docker build -f docker/Dockerfile.frontend -t mes-frontend .
docker tag mes-frontend:latest $FRONTEND_ECR_URL:latest
docker push $FRONTEND_ECR_URL:latest

# Step 3: Update ECS services
echo "Updating ECS services..."
aws ecs update-service --cluster mes-cluster --service mes-backend-service --force-new-deployment --region $AWS_REGION
aws ecs update-service --cluster mes-cluster --service mes-frontend-service --force-new-deployment --region $AWS_REGION

echo "Deployment completed successfully!"
echo "Access your application at: http://$(cd infrastructure && terraform output -raw alb_dns_name)"