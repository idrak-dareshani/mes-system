@echo off
REM MES System Deployment Script for Windows
setlocal enabledelayedexpansion

echo Starting MES deployment...

REM Configuration
set AWS_REGION=us-east-1

REM Get AWS Account ID
for /f "tokens=*" %%i in ('aws sts get-caller-identity --query Account --output text') do set AWS_ACCOUNT_ID=%%i

echo AWS Account ID: %AWS_ACCOUNT_ID%
echo AWS Region: %AWS_REGION%

REM Step 1: Deploy infrastructure
echo Deploying infrastructure...
cd infrastructure
terraform init
terraform plan -var="db_password=YourSecurePassword123!"
terraform apply -var="db_password=YourSecurePassword123!" -auto-approve

REM Get ECR repository URLs
for /f "tokens=*" %%i in ('terraform output -raw backend_ecr_url') do set BACKEND_ECR_URL=%%i
for /f "tokens=*" %%i in ('terraform output -raw frontend_ecr_url') do set FRONTEND_ECR_URL=%%i

echo Backend ECR URL: %BACKEND_ECR_URL%
echo Frontend ECR URL: %FRONTEND_ECR_URL%

cd ..

REM Step 2: Build and push Docker images
echo Building and pushing Docker images...

REM Login to ECR
aws ecr get-login-password --region %AWS_REGION% | docker login --username AWS --password-stdin %AWS_ACCOUNT_ID%.dkr.ecr.%AWS_REGION%.amazonaws.com

REM Build and push backend
echo Building backend image...
docker build -f docker/Dockerfile.backend -t mes-backend .
docker tag mes-backend:latest %BACKEND_ECR_URL%:latest
docker push %BACKEND_ECR_URL%:latest

REM Build and push frontend
echo Building frontend image...
docker build -f docker/Dockerfile.frontend -t mes-frontend .
docker tag mes-frontend:latest %FRONTEND_ECR_URL%:latest
docker push %FRONTEND_ECR_URL%:latest

REM Step 3: Update ECS services
echo Updating ECS services...
aws ecs update-service --cluster mes-cluster --service mes-backend-service --force-new-deployment --region %AWS_REGION%
aws ecs update-service --cluster mes-cluster --service mes-frontend-service --force-new-deployment --region %AWS_REGION%

echo Deployment completed successfully!

REM Get ALB DNS name
cd infrastructure
for /f "tokens=*" %%i in ('terraform output -raw alb_dns_name') do set ALB_DNS=%%i
echo Access your application at: http://!ALB_DNS!

pause