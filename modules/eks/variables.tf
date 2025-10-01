variable "prefix_name" {
  type        = string
  description = "Prefix name for resources"

}

variable "environment" {
  type        = string
  description = "Region where the cluster will be provisioned"
}

variable "private_subnets" {
  type        = list(string)
  description = "app subnet id"
}

variable "cluster_endpoint_public_access" {
  type        = bool
  description = "cluster with public endpoint"
}

variable "cluster_version" {
  type        = string
  description = "Kubernetes EKS Version"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID"
}

variable "namespaces" {
  type        = list(string)
  description = "Namespaces that must be created in the cluster"
}

variable "instance_type_node_eks" {
  type        = string
  description = "Instance type of the worker nodes"
}