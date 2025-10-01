#========================================================================================#
#                                  VPC VARIABLES                                         #
#========================================================================================#

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
}

variable "number_of_azs" {
  description = "Number of Availability Zones"
  type        = number
}

variable "enable_ipv6" {
  description = "Enable IPv6 for VPC"
  type        = bool
}

variable "create_app_subnets" {
  description = "Create application subnets"
  type        = bool
}

variable "create_data_subnets" {
  description = "Create data subnets"
  type        = bool
}

variable "create_nat" {
  description = "Create NAT Gateway"
  type        = bool
}

variable "nat_gateway_high_availability" {
  description = "Enable high availability for NAT Gateway"
  type        = bool
}



variable "environment_name" {
  description = "Environment name"
  type        = string
}

variable "create_public_subnets" {
  description = "Create public subnets"
  type        = bool
}

variable "prefix_name" {
  description = "Prefix for resource names"
  type        = string
}

#========================================================================================#
#                               API GATEWAY VARIABLES                                   #
#========================================================================================#

variable "api_gateway_cors" {
  description = "CORS configuration for API Gateway"
  type = object({
    allow_credentials = optional(bool, false)
    allow_headers     = optional(list(string), ["*"])
    allow_methods     = optional(list(string), ["*"])
    allow_origins     = optional(list(string), ["*"])
    expose_headers    = optional(list(string), [])
    max_age           = optional(number, 86400)
  })
  default = {}
}

variable "api_gateway_throttle" {
  description = "Throttling settings for API Gateway"
  type = object({
    burst_limit = optional(number, 5000)
    rate_limit  = optional(number, 10000)
  })
  default = {}
}

#========================================================================================#
#                               API GATEWAY AUTHORIZATION ROUTES                        #
#========================================================================================#


variable "eks_nlb_listener_arn" {
  description = "arn of the EKS NLB listener for API Gateway integration"
  type        = string
  default     = ""
}



#========================================================================================#
#                                 OPENVPN VARIABLES                                      #
#========================================================================================#

variable "openvpn_instance_type" {
  description = "Instance type for OpenVPN"
  type        = string
}

variable "lambda_function_arn" {
  description = "Lambda function ARN for API Gateway authorizer"
  type        = string
  default     = "lncr-prd-custom-authorizer"
}

#========================================================================================#
#                                EKS VARIABLES                                           #
#========================================================================================#

variable "cluster_version" {
  description = "Kubernetes version for EKS cluster"
  type        = string
}

variable "namespaces" {
  description = "List of namespaces to create"
  type        = list(string)
}

variable "instance_type_node_eks" {
  description = "Instance type for EKS nodes"
  type        = string
}

#========================================================================================#
#                                ECR VARIABLES                                          #
#========================================================================================#

variable "ecr_repository_names" {
  description = "List of ECR repository names to create"
  type        = list(string)
  default     = ["app", "api", "worker"]
}

variable "ecr_image_tag_mutability" {
  description = "Image tag mutability setting for ECR repositories"
  type        = string
  default     = "MUTABLE"
}

variable "ecr_scan_on_push" {
  description = "Enable image scanning on push for ECR repositories"
  type        = bool
  default     = true
}

#========================================================================================#
#                               CODEBUILD VARIABLES                                     #
#========================================================================================#

variable "codebuild_projects" {
  description = "Map of CodeBuild projects with their configurations"
  type = map(object({
    codebuild_name  = string
    github_repo_url = string
  }))
}

variable "codebuild_compute_type" {
  description = "CodeBuild compute type"
  type        = string
  default     = "BUILD_GENERAL1_MEDIUM"
}

#========================================================================================#
#                            SECRETS MANAGER VARIABLES                                 #
#========================================================================================#

variable "secrets_manager_recovery_window" {
  description = "Number of days that AWS Secrets Manager waits before it can delete the secret"
  type        = number
  default     = 7
}

#========================================================================================#
#                               FSX OPENZFS VARIABLES                                   #
#========================================================================================#

variable "fsx_storage_capacity" {
  description = "FSx OpenZFS storage capacity in GiB"
  type        = number
  default     = 64
}

variable "fsx_throughput_capacity" {
  description = "FSx OpenZFS throughput capacity in MBps"
  type        = number
  default     = 64
}

variable "fsx_deployment_type" {
  description = "FSx OpenZFS deployment type"
  type        = string
  default     = "SINGLE_AZ_1"
}

variable "fsx_backup_retention_days" {
  description = "Number of days to retain FSx OpenZFS automatic backups"
  type        = number
  default     = 7
}

