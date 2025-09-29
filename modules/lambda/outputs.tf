output "lambda_function_arn" {
  description = "Lambda function ARN"
  value       = length(aws_lambda_function.lambda) > 0 ? aws_lambda_function.lambda[0].arn : data.aws_lambda_function.existing.arn
}

output "lambda_function_name" {
  description = "Lambda function name"
  value       = length(aws_lambda_function.lambda) > 0 ? aws_lambda_function.lambda[0].function_name : data.aws_lambda_function.existing.function_name
}

output "lambda_invoke_arn" {
  description = "Lambda function invoke ARN"
  value       = aws_lambda_function.lambda.invoke_arn
}

