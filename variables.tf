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
    max_age          = optional(number, 86400)
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
#                                 OPENVPN VARIABLES                                      #
#========================================================================================#

variable "openvpn_instance_type" {
  description = "Instance type for OpenVPN"
  type        = string
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
