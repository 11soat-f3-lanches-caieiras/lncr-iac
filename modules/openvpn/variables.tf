#========================================================================================#
#                                  VARIABLES                                             #
#========================================================================================#

variable "prefix_name" {
  description = "Prefixo para nomes dos recursos"
  type        = string
}

variable "environment_name" {
  type        = string
  description = "Environment name where resources will be provisioned. Allowed values: [prd | stg | qa | dev | labs | payer | devops]"
  validation {
    condition     = contains(["prd", "stg", "qa", "dev", "labs", "payer", "devops"], var.environment_name)
    error_message = "Value must be 'prd', 'stg', 'qa', 'dev' or 'labs'."
  }
}


#========================================================================================#
#                                 INSTANCE VARIABLES                                     #
#========================================================================================#

variable "instance_type" {
  description = "Instance type to be provisioned (must be graviton)."
  type        = string
}

variable "public_subnet_id" {
  description = "Public subnet where OpenVPN will be provisioned."
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where security group will be created."
  type        = string
}

