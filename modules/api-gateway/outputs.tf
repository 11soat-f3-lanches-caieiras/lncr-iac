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

output "stage_id" {
  description = "API Gateway stage ID"
  value       = aws_apigatewayv2_stage.default.id
}

output "eks_vpc_link_id" {
  description = "EKS VPC Link ID"
  value       = aws_apigatewayv2_vpc_link.eks_vpc_link.id
}

output "eks_vpc_link_arn" {
  description = "EKS VPC Link ARN"
  value       = aws_apigatewayv2_vpc_link.eks_vpc_link.id
}

output "eks_nlb_id" {
  description = "EKS NLB Integration ID"
  value       = aws_apigatewayv2_integration.eks_nlb.id
}

output "lambda_authorizer_id" {
  description = "Lambda Authorizer ID"
  value       = aws_apigatewayv2_authorizer.lambda_integration.id
}

output "secured_routes_list" {
  description = "Lista de todas as rotas protegidas criadas"
  value = [
    for route in aws_apigatewayv2_route.secured_route : {
      id        = route.id
      route_key = route.route_key
      api_id    = route.api_id
      target    = route.target
    }
  ]
}

output "open_routes_list" {
  description = "Lista de todas as rotas abertas criadas"
  value = [
    for route in aws_apigatewayv2_route.open_route : {
      id        = route.id
      route_key = route.route_key
      api_id    = route.api_id
      target    = route.target
    }
  ]
}