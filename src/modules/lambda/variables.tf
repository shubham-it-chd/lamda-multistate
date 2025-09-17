variable "function_name" {
  description = "Name of the Lambda function"
  type        = string
}

variable "handler" {
  description = "Lambda function entry point (required for Zip packages, optional for Image)"
  type        = string
  default     = null
}

variable "runtime" {
  description = "Lambda runtime environment (required for Zip packages, not used for Image)"
  type        = string
  default     = "python3.9"
}

variable "iam_role_arn" {
  description = "ARN of the IAM role for Lambda execution"
  type        = string
}

variable "environment_variables" {
  description = "Environment variables for the Lambda function"
  type        = map(string)
  default     = null
}

variable "package_type" {
  description = "Lambda deployment package type (Zip or Image)"
  type        = string
  default     = "Zip"
  
  validation {
    condition     = contains(["Zip", "Image"], var.package_type)
    error_message = "Package type must be either 'Zip' or 'Image'."
  }
}

variable "source_code_path" {
  description = "Path to the Lambda function source code file (used when package_type is Zip)"
  type        = string
  default     = null
}

variable "image_uri" {
  description = "URI of the container image in Amazon ECR (used when package_type is Image)"
  type        = string
  default     = null
}

variable "image_config" {
  description = "Configuration for container image (command, entry_point, working_directory)"
  type = object({
    command           = optional(list(string))
    entry_point       = optional(list(string))
    working_directory = optional(string)
  })
  default = null
}

# Validation locals - these help ensure required variables are provided for each package type
locals {
  zip_package_valid = var.package_type == "Zip" ? (
    var.source_code_path != null && 
    var.handler != null && 
    var.runtime != null
  ) : true
  
  image_package_valid = var.package_type == "Image" ? (
    var.image_uri != null
  ) : true
}

variable "timeout" {
  description = "Lambda function timeout in seconds"
  type        = number
  default     = 30
}

variable "memory_size" {
  description = "Memory allocated to the Lambda function in MB"
  type        = number
  default     = 128
}

variable "subnet_ids" {
  description = "List of subnet IDs for VPC configuration"
  type        = list(string)
  default     = null
}

variable "security_group_ids" {
  description = "List of security group IDs for VPC configuration"
  type        = list(string)
  default     = null
}

variable "log_retention_days" {
  description = "CloudWatch log retention in days"
  type        = number
  default     = 14
}

variable "tags" {
  description = "Tags to apply to Lambda resources"
  type        = map(string)
  default     = {}
}

# Optional enhancements
variable "description" {
  description = "Description of the Lambda function"
  type        = string
  default     = null
}

variable "publish" {
  description = "Whether to publish a new version on updates"
  type        = bool
  default     = false
}

variable "reserved_concurrent_executions" {
  description = "The amount of reserved concurrent executions for this function"
  type        = number
  default     = null
}

variable "architectures" {
  description = "Instruction set architecture for your Lambda function (x86_64 or arm64)"
  type        = list(string)
  default     = null
}

variable "kms_key_arn" {
  description = "The ARN of the KMS key used to encrypt environment variables"
  type        = string
  default     = null
}

variable "layers" {
  description = "List of Lambda layer version ARNs to attach to your function"
  type        = list(string)
  default     = null
}

variable "tracing_mode" {
  description = "X-Ray tracing mode (PassThrough or Active)"
  type        = string
  default     = null
}

variable "dead_letter_target_arn" {
  description = "The Amazon Resource Name (ARN) of an Amazon SQS queue or Amazon SNS topic"
  type        = string
  default     = null
}

variable "ephemeral_storage_size" {
  description = "The size of the function's /tmp directory in MB (512-10240)"
  type        = number
  default     = null
}

variable "file_system_config" {
  description = "Configuration for EFS access (access_point_arn, local_mount_path)"
  type = object({
    access_point_arn = string
    local_mount_path = string
  })
  default = null
}
