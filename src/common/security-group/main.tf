terraform {
  backend "s3" {
    bucket         = "terraform-state-bucket-multistate"
    key            = "common/security-group/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-state-lock"
    encrypt        = true
  }
}

# Get default VPC
data "aws_vpc" "default" {
  default = true
}

# Lambda security group
resource "aws_security_group" "lambda_sg" {
  name_prefix = "lambda-sg-"
  description = "Security group for Lambda functions"
  vpc_id      = data.aws_vpc.default.id

  # Outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "All outbound traffic"
  }

  # HTTPS outbound
  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTPS outbound"
  }

  # HTTP outbound
  egress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTP outbound"
  }

  tags = {
    Name        = "lambda-security-group"
    Environment = var.environment
    Project     = var.project_name
  }
}

# Variables
variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "project_name" {
  description = "Project name"
  type        = string
  default     = "terraform-multistate"
}

variable "vpc_id" {
  description = "VPC ID where security group will be created"
  type        = string
  default     = ""
}
