#========================================================================================#
#                                 CUSTOMER VARIABLES                                     #
#========================================================================================#

variable "prefix_name" {
  description = "Prefix for resource names"
  type        = string
}

variable "environment_name" {
  type        = string
  description = "Environment name where CodeBuild will be provisioned. Allowed values: [prd | stg | qa | dev | labs | payer | devops]"
  validation {
    condition     = contains(["prd", "stg", "qa", "dev", "labs", "payer", "devops"], var.environment_name)
    error_message = "Value must be 'prd', 'stg', 'qa', 'dev' or 'labs'."
  }
}

#========================================================================================#
#                                CODEBUILD VARIABLES                                    #
#========================================================================================#

variable "vpc_id" {
  description = "VPC ID where CodeBuild will be deployed"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for CodeBuild"
  type        = list(string)
}

variable "codebuild_projects" {
  description = "Map of CodeBuild projects with their configurations"
  type = map(object({
    codebuild_name  = string
    github_repo_url = string
  }))
}

variable "compute_type" {
  description = "CodeBuild compute type"
  type        = string
  default     = "BUILD_GENERAL1_MEDIUM"
}

variable "image" {
  description = "CodeBuild image"
  type        = string
  default     = "aws/codebuild/amazonlinux2-x86_64-standard:5.0"
}