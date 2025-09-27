#========================================================================================#
#                                      API INTEGRATION                                   #
#========================================================================================#

resource "aws_apigatewayv2_vpc_link" "eks_vpc_link" {
  name               = "eks-vpc-link"
  subnet_ids         = var.vpc_subnet_ids
  security_group_ids = var.security_group_ids
}

resource "aws_apigatewayv2_integration" "eks_nlb" {
  api_id                 = var.api_gateway_api_id
  integration_type       = "HTTP_PROXY"
  integration_method     = "ANY"
  integration_uri        = var.eks_nlb_listener_arn
  connection_type        = "VPC_LINK"
  connection_id          = aws_apigatewayv2_vpc_link.eks_vpc_link.id
  payload_format_version = "1.0"
}

resource "aws_apigatewayv2_authorizer" "lambda_integration" {
  api_id           = var.api_gateway_api_id
  authorizer_type  = "REQUEST"
  authorizer_uri   = "arn:aws:apigateway:${var.default_region}:lambda:path/2015-03-31/functions/${var.lambda_function_arn}/invocations"
  identity_sources = ["$request.header.Authorization"]
  name             = "${var.prefix_name}-${var.environment_name}-api-custom-authorizer"
  authorizer_payload_format_version = "2.0"
  enable_simple_responses = true
}

resource "aws_apigatewayv2_route" "secured_route" {
  for_each = toset(var.authorization_routes)
  api_id    = var.api_gateway_api_id
  route_key = each.value
  authorization_type = "CUSTOM"
  authorizer_id      = aws_apigatewayv2_authorizer.lambda_integration.id
  target             = "integrations/${aws_apigatewayv2_integration.eks_nlb.id}"

  lifecycle {
    ignore_changes = [route_key]
  }
}

resource "aws_apigatewayv2_route" "open_route" {
  for_each = toset(var.open_routes)
  api_id    = var.api_gateway_api_id
  route_key = each.value
  target    = "integrations/${aws_apigatewayv2_integration.eks_nlb.id}"

  lifecycle {
    ignore_changes = [route_key]
  }
}








