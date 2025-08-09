# Terraform Backend Configuration
# Uncomment and configure after creating S3 bucket and DynamoDB table

# terraform {
#   backend "s3" {
#     bucket         = "mes-terraform-state-bucket"
#     key            = "terraform.tfstate"
#     region         = "us-east-1"
#     dynamodb_table = "mes-terraform-locks"
#     encrypt        = true
#   }
# }

# S3 Bucket for Terraform State (create manually first)
# resource "aws_s3_bucket" "terraform_state" {
#   bucket = "mes-terraform-state-bucket"
# }

# resource "aws_s3_bucket_versioning" "terraform_state" {
#   bucket = aws_s3_bucket.terraform_state.id
#   versioning_configuration {
#     status = "Enabled"
#   }
# }

# DynamoDB Table for State Locking (create manually first)
# resource "aws_dynamodb_table" "terraform_locks" {
#   name           = "mes-terraform-locks"
#   billing_mode   = "PAY_PER_REQUEST"
#   hash_key       = "LockID"

#   attribute {
#     name = "LockID"
#     type = "S"
#   }
# }