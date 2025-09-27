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
    kubernetes   = kubernetes
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
#                              ALB CONTROLLER MODULE                                    #
#========================================================================================#

# module "alb_controller" {
#   source = "./modules/alb-controller"
#
#   cluster_name                        = module.eks.cluster_name
#   region                             = "us-east-1"
#   cluster_certificate_authority_data = module.eks.cluster_certificate_authority_data
#   cluster_endpoint                   = module.eks.cluster_endpoint
#   vpc_id                            = module.vpc.vpc_id
#   alb_name                          = "${local.prefix_name}-${local.environment_name}-alb"
#   oidc_provider                     = module.eks.oidc_provider_arn
#   group_name                        = "${local.prefix_name}-${local.environment_name}"
#   namespace                         = "kube-system"
#   alb-sg                           = module.eks.cluster_security_group_id
#   public_subnets                   = module.vpc.public_subnet_ids
#
#   depends_on = [module.eks]
# }

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

#========================================================================================#
#                                API GATEWAY MODULE                                     #
#========================================================================================#

module "api_gateway" {
  source = "./modules/api-gateway"

  prefix_name      = local.prefix_name
  environment_name = local.environment_name

  cors_configuration = var.api_gateway_cors
  throttle_settings  = var.api_gateway_throttle
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
#                             SECRETS MANAGER MODULE                                    #
#========================================================================================#

module "secrets_manager" {
  source = "./modules/secrets-manager"

  prefix_name      = local.prefix_name
  environment_name = local.environment_name

  recovery_window_in_days = var.secrets_manager_recovery_window
}

#========================================================================================#
#                               FSX OPENZFS MODULE                                      #
#========================================================================================#

module "fsx_openzfs" {
  source = "./modules/fsx-openzfs"

  prefix_name      = local.prefix_name
  environment_name = local.environment_name

  vpc_id                         = module.vpc.vpc_id
  subnet_ids                      = [module.vpc.app_subnet_ids[0]]
  storage_capacity               = var.fsx_storage_capacity
  throughput_capacity            = var.fsx_throughput_capacity
  deployment_type                = var.fsx_deployment_type
  automatic_backup_retention_days = var.fsx_backup_retention_days
}

#========================================================================================#
#                          API GATEWAY INTEGRATION (FASE 3)                            #
#========================================================================================#

module "api-gateway-configuration" {
  source = "./modules/api-gateway-configuration"

  prefix_name          = local.prefix_name
  environment_name     = local.environment_name
  api_gateway_api_id   = module.api_gateway.api_id
  lambda_function_arn  = var.lambda_function_arn
  vpc_subnet_ids       = module.vpc.app_subnet_ids
  security_group_ids = [module.eks.cluster_security_group_id]
  eks_nlb_listener_arn = var.eks_nlb_listener_arn

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