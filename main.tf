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

  environment_variables = {
    ENVIRONMENT = local.environment_name
    PREFIX      = local.prefix_name
  }
}

resource "aws_lambda_permission" "api_gateway_invoke" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = module.lambda.lambda_function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${module.api_gateway.execution_arn}/*/*"
}

module "api_gateway" {
  source = "./modules/api-gateway"

  prefix_name      = local.prefix_name
  environment_name = local.environment_name

  cors_configuration = var.api_gateway_cors
  throttle_settings  = var.api_gateway_throttle
  lambda_invoke_arn  = module.lambda.lambda_invoke_arn
}

#========================================================================================#
#                                ECR MODULE                                             #
#========================================================================================#

module "ecr" {
  source = "./modules/ecr"

  prefix_name      = local.prefix_name
  environment_name = local.environment_name

  repository_names      = var.ecr_repository_names
  image_tag_mutability = var.ecr_image_tag_mutability
  scan_on_push         = var.ecr_scan_on_push
}

#========================================================================================#
#                               CODEBUILD MODULE                                        #
#========================================================================================#

module "codebuild" {
  source = "./modules/codebuild"

  prefix_name      = local.prefix_name
  environment_name = local.environment_name

  vpc_id         = module.vpc.vpc_id
  subnet_ids     = module.vpc.app_subnet_ids
  github_repo_url = var.codebuild_github_repo_url
  compute_type   = var.codebuild_compute_type
}

#========================================================================================#
#                                  OUTPUTS                                              #
#========================================================================================#

output "codebuild_project_name" {
  description = "CodeBuild project name"
  value       = module.codebuild.codebuild_project_name
}

output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}