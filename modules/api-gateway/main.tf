#========================================================================================#
#                                  API GATEWAY V2                                        #
#========================================================================================#

resource "aws_apigatewayv2_api" "api" {
  name          = "${var.prefix_name}-${var.environment_name}-api"
  protocol_type = "HTTP"
  description   = "API Gateway HTTP v2 for ${var.prefix_name} ${var.environment_name}"

  cors_configuration {
    allow_credentials = var.cors_configuration.allow_credentials
    allow_headers     = var.cors_configuration.allow_headers
    allow_methods     = var.cors_configuration.allow_methods
    allow_origins     = var.cors_configuration.allow_origins
    expose_headers    = var.cors_configuration.expose_headers
    max_age           = var.cors_configuration.max_age
  }

  tags = {
    Name        = "${var.prefix_name}-${var.environment_name}-api"
    Environment = var.environment_name
    Owner       = "Fiap"
    CostCenter  = "FinOps"
  }
}

resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.api.id
  name        = "$default"
  auto_deploy = true

  default_route_settings {
    throttling_burst_limit = var.throttle_settings.burst_limit
    throttling_rate_limit  = var.throttle_settings.rate_limit
  }

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api_gateway_prd.arn
    format = jsonencode({
      requestId      = "$context.requestId"
      ip             = "$context.identity.sourceIp"
      requestTime    = "$context.requestTime"
      httpMethod     = "$context.httpMethod"
      routeKey       = "$context.routeKey"
      status         = "$context.status"
      protocol       = "$context.protocol"
      responseLength = "$context.responseLength"
      error          = "$context.error.message"
    })
  }

  tags = {
    Name        = "${var.prefix_name}-${var.environment_name}-api-stage"
    Environment = var.environment_name
    Owner       = "fiap"
    CostCenter  = "FinOps"
  }

}

#========================================================================================#
#                          API INTEGRATION AND AUTHORIZATION                             #
#========================================================================================#


resource "aws_apigatewayv2_vpc_link" "eks_vpc_link" {
  name               = "eks-vpc-link"
  subnet_ids         = var.vpc_subnet_ids
  security_group_ids = var.security_group_ids
}

resource "aws_apigatewayv2_integration" "eks_nlb" {
  api_id                 = aws_apigatewayv2_api.api.id
  integration_type       = "HTTP_PROXY"
  integration_method     = "ANY"
  integration_uri        = var.eks_nlb_listener_arn
  connection_type        = "VPC_LINK"
  connection_id          = aws_apigatewayv2_vpc_link.eks_vpc_link.id
  payload_format_version = "1.0"
}

resource "aws_apigatewayv2_authorizer" "lambda_integration" {
  api_id                            = aws_apigatewayv2_api.api.id
  authorizer_type                   = "REQUEST"
  authorizer_uri                    = "arn:aws:apigateway:${var.default_region}:lambda:path/2015-03-31/functions/${var.lambda_function_arn}/invocations"
  identity_sources                  = ["$request.header.Authorization"]
  name                              = "${var.prefix_name}-${var.environment_name}-api-custom-authorizer"
  authorizer_payload_format_version = "2.0"
  enable_simple_responses           = true
}

resource "aws_apigatewayv2_route" "secured_route" {
  for_each           = toset(var.authorization_routes)
  api_id             = aws_apigatewayv2_api.api.id
  route_key          = each.value
  authorization_type = "CUSTOM"
  authorizer_id      = aws_apigatewayv2_authorizer.lambda_integration.id
  target             = "integrations/${aws_apigatewayv2_integration.eks_nlb.id}"

  lifecycle {
    ignore_changes = [route_key]
  }
}

resource "aws_apigatewayv2_route" "open_route" {
  for_each  = toset(var.open_routes)
  api_id    = aws_apigatewayv2_api.api.id
  route_key = each.value
  target    = "integrations/${aws_apigatewayv2_integration.eks_nlb.id}"

  lifecycle {
    ignore_changes = [route_key]
  }
}

#========================================================================================#
#                                  CLOUDWATCH LOGS                                      #
#========================================================================================#

resource "aws_cloudwatch_log_group" "api_gateway" {
  name              = "/aws/apigateway/${var.prefix_name}-${var.environment_name}-api"
  retention_in_days = 14

  tags = {
    Name        = "${var.prefix_name}-${var.environment_name}-api-logs"
    Environment = var.environment_name
    Owner       = "fiap"
    CostCenter  = "FinOps"
  }
}

resource "aws_cloudwatch_log_group" "api_gateway_prd" {
  name              = "/aws/apigateway/${var.prefix_name}-${var.environment_name}-api-prd"
  retention_in_days = 30

  tags = {
    Name        = "${var.prefix_name}-${var.environment_name}-api-prd-logs"
    Environment = var.environment_name
    Owner       = "fiap"
    CostCenter  = "FinOps"
  }
}