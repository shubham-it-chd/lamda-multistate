output "lambda_function_arn" {
  description = "ARN of the Lambda function"
  value       = aws_lambda_function.lambda_function.arn
}

output "lambda_function_name" {
  description = "Name of the Lambda function"
  value       = aws_lambda_function.lambda_function.function_name
}

output "lambda_function_invoke_arn" {
  description = "Invoke ARN of the Lambda function"
  value       = aws_lambda_function.lambda_function.invoke_arn
}

output "lambda_function_qualified_arn" {
  description = "Qualified ARN of the Lambda function"
  value       = aws_lambda_function.lambda_function.qualified_arn
}

output "lambda_function_version" {
  description = "Version of the Lambda function"
  value       = aws_lambda_function.lambda_function.version
}

output "cloudwatch_log_group_name" {
  description = "Name of the CloudWatch log group"
  value       = aws_cloudwatch_log_group.lambda_logs.name
}

output "cloudwatch_log_group_arn" {
  description = "ARN of the CloudWatch log group"
  value       = aws_cloudwatch_log_group.lambda_logs.arn
}

output "lambda_package_type" {
  description = "Package type of the Lambda function (Zip or Image)"
  value       = aws_lambda_function.lambda_function.package_type
}

output "lambda_image_uri" {
  description = "URI of the container image (only for Image packages)"
  value       = var.package_type == "Image" ? aws_lambda_function.lambda_function.image_uri : null
}