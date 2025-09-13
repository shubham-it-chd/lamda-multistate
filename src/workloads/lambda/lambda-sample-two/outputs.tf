output "lambda_function_arn" {
  description = "ARN of the Lambda function"
  value       = module.lambda_sample_two.lambda_function_arn
}

output "lambda_function_name" {
  description = "Name of the Lambda function"
  value       = module.lambda_sample_two.lambda_function_name
}

output "lambda_function_invoke_arn" {
  description = "Invoke ARN of the Lambda function"
  value       = module.lambda_sample_two.lambda_function_invoke_arn
}

output "cloudwatch_log_group_name" {
  description = "Name of the CloudWatch log group"
  value       = module.lambda_sample_two.cloudwatch_log_group_name
}

output "lambda_function_qualified_arn" {
  description = "Qualified ARN of the Lambda function"
  value       = module.lambda_sample_two.lambda_function_qualified_arn
}

# Referenced IAM and Security Group outputs from remote state
output "iam_role_arn" {
  description = "ARN of the IAM role used by Lambda (from common/iam)"
  value       = data.terraform_remote_state.iam.outputs.lambda_execution_role_arn
}

output "security_group_id" {
  description = "ID of the security group (from common/security-group)"
  value       = data.terraform_remote_state.security_group.outputs.lambda_security_group_id
}
