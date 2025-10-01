#========================================================================================#
#                                  LAMBDA RESOURCES                                      #
#========================================================================================#

data "archive_file" "lambda_zip" {
  type        = "zip"
  output_path = "${path.module}/lambda.zip"
  source_file = "${path.module}/templates/placeholder.js"
}

data "aws_lambda_function" "existing" {
  function_name = "${var.prefix_name}-${var.environment_name}-${var.function_name}"

  lifecycle {
    postcondition {
      condition     = can(self.function_name)
      error_message = "Lambda function does not exist"
    }
  }
}

resource "aws_lambda_function" "lambda" {
  count         = try(data.aws_lambda_function.existing.function_name, null) == null ? 1 : 0
  function_name = "${var.prefix_name}-${var.environment_name}-${var.function_name}"
  handler       = var.handler
  runtime       = var.runtime
  role          = aws_iam_role.lambda_execution_role.arn
  timeout       = var.timeout

  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  environment {
    variables = var.environment_variables
  }

  tags = {
    Name        = "${var.prefix_name}-${var.function_name}"
    Environment = var.environment_name
    Owner       = "Fiap"
    CostCenter  = "FinOps"
  }

  depends_on = [data.archive_file.lambda_zip]

  lifecycle {
    ignore_changes = all
  }
}



#========================================================================================#
#                               ROLE/POLICY RESOURCES                                    #
#========================================================================================#

resource "aws_iam_role" "lambda_execution_role" {
  name = "${var.prefix_name}-lambda-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { "Service" : "lambda.amazonaws.com" }
    }]
  })

  tags = {
    Name        = "${var.prefix_name}-lambda-execution-role"
    Environment = var.environment_name
    Owner       = "Fiap"
    CostCenter  = "FinOps"
  }
}

resource "aws_iam_role_policy" "lambda_policy" {
  name = "${var.prefix_name}-lambda-policy"
  role = aws_iam_role.lambda_execution_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "*"
      }
    ]
  })
}

