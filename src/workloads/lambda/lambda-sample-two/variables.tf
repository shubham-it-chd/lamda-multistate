variable "function_name" {
  description = "Name of the Lambda function"
  type        = string
  default     = "lambda-sample-two"
}

variable "handler" {
  description = "Lambda function entry point"
  type        = string
  default     = "lambda_function_two.lambda_handler"
}

variable "runtime" {
  description = "Lambda runtime environment"
  type        = string
  default     = "python3.9"
}

variable "timeout" {
  description = "Lambda function timeout in seconds"
  type        = number
  default     = 60
}

variable "memory_size" {
  description = "Memory allocated to the Lambda function in MB"
  type        = number
  default     = 256
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "custom_message" {
  description = "Custom message for the Lambda function"
  type        = string
  default     = "Hello from Lambda Sample Two - Advanced Features!"
}

variable "debug_mode" {
  description = "Enable debug mode for the Lambda function"
  type        = string
  default     = "false"
}

# Optional: switch to container image by setting these (and update package_type to "Image")
variable "image_uri" {
  description = "ECR image URI for container-based Lambda"
  type        = string
  default     = null
}

variable "image_config" {
  description = "Container image configuration"
  type = object({
    command           = optional(list(string))
    entry_point       = optional(list(string))
    working_directory = optional(string)
  })
  default = null
}

variable "enable_vpc_config" {
  description = "Enable VPC configuration for Lambda"
  type        = bool
  default     = false
}

variable "subnet_ids" {
  description = "List of subnet IDs for VPC configuration"
  type        = list(string)
  default     = []
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default = {
    Environment = "dev"
    Project     = "terraform-multistate"
    ManagedBy   = "Terraform"
  }
}
