#========================================================================================#
#                                   VPC MODULE                                           #
#========================================================================================#

module "vpc" {
  source = "./modules/vpc"

  prefix_name          = local.prefix_name
  environment          = local.environment_name
  enable_vpc_flow_logs = false

  vpc_cidr = var.vpc_cidr

  number_of_azs = var.number_of_azs

  enable_ipv6 = var.enable_ipv6

  create_app_subnets  = var.create_app_subnets
  create_data_subnets = var.create_data_subnets

  create_nat                    = var.create_nat
  nat_gateway_high_availability = var.nat_gateway_high_availability
  eks_cluster_name              = "${local.prefix_name}-${var.environment_name}-eks"
}

#========================================================================================#
#                                 OPENVPN MODULE                                         #
#========================================================================================#

module "openvpn" {
  source = "./modules/openvpn"

  prefix_name      = local.prefix_name
  environment_name = local.environment_name
  instance_type    = var.openvpn_instance_type
  vpc_id           = module.vpc.vpc_id
  public_subnet_id = module.vpc.public_subnet_ids[0]
}

#========================================================================================#
#                                 EKS MODULE                                             #
#========================================================================================#

module "eks" {
  source = "./modules/eks"

  providers = {
    aws.virginia = aws.virginia
  }

  prefix_name                    = local.prefix_name
  environment                    = var.environment_name
  private_subnets                = module.vpc.app_subnet_ids
  cluster_endpoint_public_access = false
  cluster_version                = var.cluster_version
  vpc_id                         = module.vpc.vpc_id
  namespaces                     = var.namespaces
  instance_type_node_eks         = var.instance_type_node_eks
}

#========================================================================================#
#                                API GATEWAY MODULE                                     #
#========================================================================================#

#========================================================================================#
#                                LAMBDA MODULE                                          #
#========================================================================================#

module "lambda" {
  source = "./modules/lambda"

  prefix_name      = local.prefix_name
  environment_name = local.environment_name
  function_name    = "customer-authorizer"

  api_gateway_execution_arn = module.api_gateway.execution_arn

  environment_variables = {
    ENVIRONMENT = local.environment_name
    PREFIX      = local.prefix_name
  }
}

module "api_gateway" {
  source = "./modules/api-gateway"

  prefix_name      = local.prefix_name
  environment_name = local.environment_name

  cors_configuration = var.api_gateway_cors
  throttle_settings  = var.api_gateway_throttle
  lambda_invoke_arn  = module.lambda.lambda_invoke_arn
}