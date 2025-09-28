#========================================================================================#
#                                  API GATEWAY V2                                        #
#========================================================================================#

resource "aws_apigatewayv2_api" "api" {
  name          = "${var.prefix_name}-${var.environment_name}-api"
  protocol_type = "HTTP"
  body          = file("${path.module}/lncr-prd-api.yaml")


  cors_configuration {
    allow_credentials = var.cors_configuration.allow_credentials
    allow_headers     = var.cors_configuration.allow_headers
    allow_methods     = var.cors_configuration.allow_methods
    allow_origins     = var.cors_configuration.allow_origins
    expose_headers    = var.cors_configuration.expose_headers
    max_age          = var.cors_configuration.max_age
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

  tags = {
    Name        = "${var.prefix_name}-${var.environment_name}-api-stage"
    Environment = var.environment_name
    Owner       = "fiap"
    CostCenter  = "FinOps"
  }
}

resource "aws_apigatewayv2_stage" "v2" {
  api_id      = aws_apigatewayv2_api.api.id
  name        = "v2"
  auto_deploy = true

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api_gateway_prd.arn
    format = jsonencode({
      requestId      = "$context.requestId"
      ip            = "$context.identity.sourceIp"
      requestTime   = "$context.requestTime"
      httpMethod    = "$context.httpMethod"
      routeKey      = "$context.routeKey"
      status        = "$context.status"
      protocol      = "$context.protocol"
      responseLength = "$context.responseLength"
      error         = "$context.error.message"
    })
  }

  default_route_settings {
    throttling_burst_limit = var.throttle_settings.burst_limit
    throttling_rate_limit  = var.throttle_settings.rate_limit
  }

  tags = {
    Name        = "${var.prefix_name}-${var.environment_name}-api-prd-stage"
    Environment = var.environment_name
    Owner       = "fiap"
    CostCenter  = "FinOps"
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