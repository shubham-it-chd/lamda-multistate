output "lambda_security_group_id" {
  description = "ID of the Lambda security group"
  value       = aws_security_group.lambda_sg.id
}

output "lambda_security_group_name" {
  description = "Name of the Lambda security group"
  value       = aws_security_group.lambda_sg.name
}

output "vpc_id" {
  description = "VPC ID where security group was created"
  value       = data.aws_vpc.default.id
}
