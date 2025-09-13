# Terraform Multistate Project

This project demonstrates a Terraform multistate architecture with shared common resources and independent workloads.

## Project Structure

```
src/
├── common/
│   ├── iam/                    # Shared IAM resources
│   │   ├── main.tf
│   │   └── outputs.tf
│   └── security-group/         # Shared Security Group resources
│       ├── main.tf
│       └── outputs.tf
├── modules/
│   └── lambda/                 # Reusable Lambda module
│       ├── main.tf
│       ├── variables.tf
│       └── outputs.tf
└── workloads/
    └── lambda/
        ├── lambda-sample-one/  # First Lambda workload
        │   ├── main.tf
        │   ├── variables.tf
        │   ├── outputs.tf
        │   └── lambda_function_one.py
        └── lambda-sample-two/  # Second Lambda workload
            ├── main.tf
            ├── variables.tf
            ├── outputs.tf
            └── lambda_function_two.py
backend.tf                      # Remote state configuration
provider.tf                     # AWS provider configuration
variables.tf                    # Common variables
```

## Prerequisites

1. **AWS CLI configured** with appropriate credentials
2. **Terraform >= 1.0** installed
3. **S3 bucket** for state storage: `terraform-state-bucket-multistate`
4. **DynamoDB table** for state locking: `terraform-state-lock`

### Setting up the Backend Infrastructure

Before using this project, create the required S3 bucket and DynamoDB table:

```bash
# Create S3 bucket for state storage
aws s3 mb s3://terraform-state-bucket-multistate --region us-east-1

# Enable versioning on the bucket
aws s3api put-bucket-versioning \
    --bucket terraform-state-bucket-multistate \
    --versioning-configuration Status=Enabled

# Create DynamoDB table for state locking
aws dynamodb create-table \
    --table-name terraform-state-lock \
    --attribute-definitions AttributeName=LockID,AttributeType=S \
    --key-schema AttributeName=LockID,KeyType=HASH \
    --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5 \
    --region us-east-1
```

## Deployment Order

### 1. Deploy Common Resources

Deploy shared resources first, as workloads depend on them:

```bash
# Deploy IAM resources
cd src/common/iam
terraform init
terraform plan
terraform apply

# Deploy Security Group resources
cd ../security-group
terraform init
terraform plan
terraform apply
```

### 2. Deploy Workloads

Deploy workloads independently:

```bash
# Deploy Lambda Sample One
cd ../../workloads/lambda/lambda-sample-one
terraform init
terraform plan
terraform apply

# Deploy Lambda Sample Two
cd ../lambda-sample-two
terraform init
terraform plan
terraform apply
```

## State Management

Each component maintains its own state file:

- **Common IAM**: `s3://terraform-state-bucket-multistate/common/iam/terraform.tfstate`
- **Common Security Group**: `s3://terraform-state-bucket-multistate/common/security-group/terraform.tfstate`
- **Lambda Sample One**: `s3://terraform-state-bucket-multistate/workloads/lambda/lambda-sample-one/terraform.tfstate`
- **Lambda Sample Two**: `s3://terraform-state-bucket-multistate/workloads/lambda/lambda-sample-two/terraform.tfstate`

Workloads reference common resources using `terraform_remote_state` data sources.

## Features

### Common Resources

- **IAM Role**: Lambda execution role with basic and VPC execution policies
- **Security Group**: Default security group for Lambda functions with outbound internet access

### Lambda Module

The reusable Lambda module supports:

- Configurable function name, handler, and runtime
- Environment variables
- VPC configuration (optional)
- CloudWatch log groups with configurable retention
- Custom IAM roles
- Tagging

### Lambda Workloads

#### Lambda Sample One
- Basic Lambda function with simple event processing
- Environment variables for configuration
- JSON response with function metadata

#### Lambda Sample Two
- Advanced Lambda function with AWS SDK usage
- Multiple event type processing (API Gateway, SQS, S3)
- Enhanced error handling and logging
- Account information retrieval

## Configuration

### Environment Variables

Each workload can be customized through variables:

```hcl
# In workload variables.tf or terraform.tfvars
function_name = "my-custom-lambda"
environment   = "prod"
timeout       = 300
memory_size   = 512
enable_vpc_config = true
```

### VPC Configuration

To enable VPC configuration for Lambda functions:

1. Set `enable_vpc_config = true`
2. Provide `subnet_ids` list
3. Security group will be automatically referenced from common resources

## Testing Lambda Functions

After deployment, test the functions:

```bash
# Test Lambda Sample One
aws lambda invoke \
    --function-name lambda-sample-one \
    --payload '{"test": "data"}' \
    response.json

# Test Lambda Sample Two with event type
aws lambda invoke \
    --function-name lambda-sample-two \
    --payload '{"eventType": "api_gateway", "httpMethod": "GET", "path": "/test"}' \
    response.json
```

## Cleanup

To destroy resources, run in reverse order:

```bash
# Destroy workloads first
cd src/workloads/lambda/lambda-sample-two
terraform destroy

cd ../lambda-sample-one
terraform destroy

# Then destroy common resources
cd ../../common/security-group
terraform destroy

cd ../iam
terraform destroy
```

## Best Practices Implemented

1. **State Isolation**: Each component has its own state file
2. **Remote State Sharing**: Workloads reference common resources via remote state
3. **Modular Design**: Reusable Lambda module with configurable parameters
4. **Tagging Strategy**: Consistent tagging across all resources
5. **Environment Variables**: Configurable function behavior
6. **Error Handling**: Comprehensive error handling in Lambda functions
7. **Logging**: CloudWatch integration with configurable retention
8. **Security**: IAM roles with least privilege principles

## Troubleshooting

### Common Issues

1. **State Lock**: If state is locked, check DynamoDB table for stuck locks
2. **Permissions**: Ensure AWS credentials have sufficient permissions
3. **Backend**: Verify S3 bucket and DynamoDB table exist before deployment
4. **Dependencies**: Deploy common resources before workloads

### Useful Commands

```bash
# Check current state
terraform show

# List resources in state
terraform state list

# Import existing resources
terraform import aws_lambda_function.example function-name

# Force unlock state (use with caution)
terraform force-unlock LOCK_ID
```
