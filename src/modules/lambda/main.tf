# Archive the Lambda function code (only for Zip packages)
data "archive_file" "lambda_zip" {
  count       = var.package_type == "Zip" ? 1 : 0
  type        = "zip"
  source_file = var.source_code_path
  output_path = "${path.module}/lambda_function.zip"
}

# Lambda function
resource "aws_lambda_function" "lambda_function" {
  # Conditional configuration based on package type
  package_type     = var.package_type
  function_name    = var.function_name
  role            = var.iam_role_arn
  timeout         = var.timeout
  memory_size     = var.memory_size
  description      = var.description
  publish          = var.publish
  reserved_concurrent_executions = var.reserved_concurrent_executions
  architectures    = var.architectures
  kms_key_arn      = var.kms_key_arn
  layers           = var.layers
  
  # ZIP package configuration
  filename         = var.package_type == "Zip" ? data.archive_file.lambda_zip[0].output_path : null
  handler         = var.package_type == "Zip" ? var.handler : null
  runtime         = var.package_type == "Zip" ? var.runtime : null
  source_code_hash = var.package_type == "Zip" ? data.archive_file.lambda_zip[0].output_base64sha256 : null
  
  # Container image configuration
  image_uri = var.package_type == "Image" ? var.image_uri : null
  
  # Image configuration block for container images
  dynamic "image_config" {
    for_each = var.package_type == "Image" && var.image_config != null ? [1] : []
    content {
      command           = var.image_config.command
      entry_point       = var.image_config.entry_point
      working_directory = var.image_config.working_directory
    }
  }

  # X-Ray tracing configuration
  dynamic "tracing_config" {
    for_each = var.tracing_mode != null ? [1] : []
    content {
      mode = var.tracing_mode
    }
  }

  # Dead-letter queue configuration
  dynamic "dead_letter_config" {
    for_each = var.dead_letter_target_arn != null ? [1] : []
    content {
      target_arn = var.dead_letter_target_arn
    }
  }

  # Ephemeral storage configuration (512-10240 MB)
  dynamic "ephemeral_storage" {
    for_each = var.ephemeral_storage_size != null ? [1] : []
    content {
      size = var.ephemeral_storage_size
    }
  }

  # EFS file system configuration
  dynamic "file_system_config" {
    for_each = var.file_system_config != null ? [1] : []
    content {
      arn              = var.file_system_config.access_point_arn
      local_mount_path = var.file_system_config.local_mount_path
    }
  }

  dynamic "environment" {
    for_each = var.environment_variables != null ? [1] : []
    content {
      variables = var.environment_variables
    }
  }

  dynamic "vpc_config" {
    for_each = var.subnet_ids != null && var.security_group_ids != null ? [1] : []
    content {
      subnet_ids         = var.subnet_ids
      security_group_ids = var.security_group_ids
    }
  }

  tags = merge(
    {
      Name = var.function_name
    },
    var.tags
  )

  depends_on = [
    data.archive_file.lambda_zip
  ]

  lifecycle {
    precondition {
      condition     = var.package_type != "Zip" || (var.source_code_path != null && var.handler != null && var.runtime != null)
      error_message = "For Zip packages, provide non-null values for source_code_path, handler, and runtime."
    }
    precondition {
      condition     = var.package_type != "Image" || (var.image_uri != null)
      error_message = "For Image packages, provide a non-null image_uri."
    }
    precondition {
      condition     = var.ephemeral_storage_size == null || (var.ephemeral_storage_size >= 512 && var.ephemeral_storage_size <= 10240)
      error_message = "ephemeral_storage_size must be between 512 and 10240 MB."
    }
    precondition {
      condition     = var.architectures == null || length(setsubtract(var.architectures, ["x86_64", "arm64"])) == 0
      error_message = "architectures must be a list containing only 'x86_64' and/or 'arm64'."
    }
  }
}

# CloudWatch Log Group
resource "aws_cloudwatch_log_group" "lambda_logs" {
  name              = "/aws/lambda/${var.function_name}"
  retention_in_days = var.log_retention_days

  tags = merge(
    {
      Name = "${var.function_name}-logs"
    },
    var.tags
  )
}
