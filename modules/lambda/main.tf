#========================================================================================#
#                                  LAMBDA RESOURCES                                      #
#========================================================================================#

resource "aws_lambda_function" "lambda" {
  function_name = "${var.prefix_name}-${var.environment_name}-${var.function_name}"
  handler       = var.handler
  runtime       = var.runtime
  role          = aws_iam_role.lambda_execution_role.arn
  timeout       = var.timeout

  environment {
    variables = var.environment_variables
  }

  filename = data.archive_file.lambda_zip.output_path

  tags = {
    Name        = "${var.prefix_name}-${var.environment_name}-${var.function_name}"
    Environment = var.environment_name
    Owner       = "Fiap"
    CostCenter  = "FinOps"
  }
}

resource "aws_lambda_permission" "api_gateway_invoke" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${var.api_gateway_execution_arn}/*/*"
}

#========================================================================================#
#                               ROLE/POLICY RESOURCES                                    #
#========================================================================================#

resource "aws_iam_role" "lambda_execution_role" {
  name = "${var.prefix_name}-${var.environment_name}-lambda-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { "Service" : "lambda.amazonaws.com" }
    }]
  })

  tags = {
    Name        = "${var.prefix_name}-${var.environment_name}-lambda-execution-role"
    Environment = var.environment_name
    Owner       = "Fiap"
    CostCenter  = "FinOps"
  }
}

resource "aws_iam_role_policy" "lambda_policy" {
  name = "${var.prefix_name}-${var.environment_name}-lambda-policy"
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

#========================================================================================#
#                                  DATA SOURCES                                          #
#========================================================================================#

data "archive_file" "lambda_zip" {
  type        = "zip"
  output_path = "/tmp/${var.prefix_name}-${var.environment_name}-${var.function_name}.zip"
  
  source {
    content = templatefile("${path.module}/templates/lambda_function.py", {
      environment = var.environment_name
    })
    filename = "index.py"
  }
}