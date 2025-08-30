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
    max_age          = var.cors_configuration.max_age
  }

  tags = {
    Name        = "${var.prefix_name}-${var.environment_name}-api"
    Environment = var.environment_name
    Owner       = "CloudDog"
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
    Owner       = "CloudDog"
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
    Owner       = "CloudDog"
    CostCenter  = "FinOps"
  }
}