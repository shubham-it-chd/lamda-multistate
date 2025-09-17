terraform {
  backend "s3" {
    bucket         = "terraform-state-bucket-multistate"
    key            = "workloads/lambda/lambda-sample-two/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-state-lock"
    encrypt        = true
  }
}

# Data sources to get remote state from common modules
data "terraform_remote_state" "iam" {
  backend = "s3"
  config = {
    bucket = "terraform-state-bucket-multistate"
    key    = "common/iam/terraform.tfstate"
    region = "us-east-1"
  }
}

data "terraform_remote_state" "security_group" {
  backend = "s3"
  config = {
    bucket = "terraform-state-bucket-multistate"
    key    = "common/security-group/terraform.tfstate"
    region = "us-east-1"
  }
}

# Use the Lambda module
module "lambda_sample_two" {
  source = "../../modules/lambda"

  # Packaging (keep Zip by default; switch to Image by setting image_uri below)
  package_type     = "Zip"
  function_name     = var.function_name
  handler          = var.handler
  runtime          = var.runtime
  iam_role_arn     = data.terraform_remote_state.iam.outputs.lambda_execution_role_arn
  source_code_path = "${path.module}/lambda_function_two.py"
  timeout          = var.timeout
  memory_size      = var.memory_size

  # Image-specific (set these and package_type = "Image" to use container image)
  image_uri    = var.image_uri
  image_config = var.image_config

  environment_variables = {
    ENVIRONMENT    = var.environment
    CUSTOM_MESSAGE = var.custom_message
    FUNCTION_TYPE  = "sample-two"
    DEBUG_MODE     = var.debug_mode
  }

  # VPC configuration using security group from remote state
  security_group_ids = var.enable_vpc_config ? [data.terraform_remote_state.security_group.outputs.lambda_security_group_id] : null
  subnet_ids         = var.enable_vpc_config ? var.subnet_ids : null

  tags = merge(
    var.common_tags,
    {
      Component = "lambda-sample-two"
      Type      = "workload"
      Features  = "advanced"
    }
  )
}
