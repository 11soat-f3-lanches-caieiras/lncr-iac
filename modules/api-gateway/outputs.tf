output "api_id" {
  description = "API Gateway ID"
  value       = aws_apigatewayv2_api.api.id
}

output "api_endpoint" {
  description = "API Gateway endpoint"
  value       = aws_apigatewayv2_api.api.api_endpoint
}

output "api_arn" {
  description = "API Gateway ARN"
  value       = aws_apigatewayv2_api.api.arn
}

output "stage_arn" {
  description = "API Gateway stage ARN"
  value       = aws_apigatewayv2_stage.default.arn
}

output "execution_arn" {
  description = "API Gateway execution ARN"
  value       = aws_apigatewayv2_api.api.execution_arn
}