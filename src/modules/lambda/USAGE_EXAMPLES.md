# Lambda Module Usage Examples

## ZIP Package Deployment (Default)

```hcl
module "lambda_zip_example" {
  source = "../../modules/lambda"

  package_type      = "Zip"  # Optional, defaults to "Zip"
  function_name     = "my-lambda-function"
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.11"
  source_code_path = "${path.module}/lambda_function.py"
  iam_role_arn     = aws_iam_role.lambda_role.arn
  
  timeout     = 30
  memory_size = 128

  environment_variables = {
    ENVIRONMENT = "production"
    LOG_LEVEL   = "INFO"
  }

  tags = {
    Environment = "prod"
    Component   = "api"
  }
}
```

## Container Image Deployment

```hcl
module "lambda_image_example" {
  source = "../../modules/lambda"

  package_type = "Image"
  function_name = "my-lambda-container"
  image_uri    = "123456789012.dkr.ecr.us-east-1.amazonaws.com/my-lambda:latest"
  iam_role_arn = aws_iam_role.lambda_role.arn
  
  timeout     = 60
  memory_size = 512

  # Optional: Configure container image settings
  image_config = {
    command           = ["app.handler"]
    entry_point       = ["/lambda-entrypoint.sh"]
    working_directory = "/var/task"
  }

  environment_variables = {
    ENVIRONMENT = "production"
    LOG_LEVEL   = "DEBUG"
  }

  # VPC configuration (optional)
  enable_vpc_config  = true
  subnet_ids         = ["subnet-12345", "subnet-67890"]
  security_group_ids = ["sg-abcdef123"]

  tags = {
    Environment = "prod"
    Component   = "api"
    PackageType = "container"
  }
}
```

## Variables Reference

### Required Variables
- `function_name`: Name of the Lambda function
- `iam_role_arn`: ARN of the IAM role for Lambda execution

### Package Type Specific Variables

#### For ZIP Packages (package_type = "Zip")
- `source_code_path`: Path to the source code file
- `handler`: Function entry point (e.g., "lambda_function.lambda_handler")
- `runtime`: Runtime environment (e.g., "python3.11", "nodejs18.x")

#### For Container Images (package_type = "Image")
- `image_uri`: URI of the container image in ECR
- `image_config`: (Optional) Container configuration object

### Optional Variables
- `package_type`: "Zip" (default) or "Image"
- `timeout`: Function timeout in seconds (default: 30)
- `memory_size`: Memory in MB (default: 128)
- `environment_variables`: Environment variables map
- `subnet_ids`: VPC subnet IDs for VPC configuration
- `security_group_ids`: Security group IDs for VPC configuration
- `log_retention_days`: CloudWatch log retention (default: 14)
- `tags`: Resource tags

## Migration from ZIP to Container

To migrate an existing ZIP-based Lambda to container:

1. Build your container image and push to ECR
2. Change the module configuration:
   ```hcl
   # From:
   package_type      = "Zip"
   source_code_path  = "..."
   handler          = "..."
   runtime          = "..."
   
   # To:
   package_type = "Image"
   image_uri    = "123456789012.dkr.ecr.us-east-1.amazonaws.com/my-app:latest"
   ```
3. Remove ZIP-specific variables (handler, runtime, source_code_path)
4. Apply the changes with `terraform apply`
