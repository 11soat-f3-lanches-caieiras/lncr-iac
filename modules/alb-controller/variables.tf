variable "cluster_name" {
  type        = string
  description = "Nome do cluster EKS."
}

variable "region" {
  type        = string
  description = "Região onde o cluster EKS está localizado."
}
variable "cluster_certificate_authority_data" {
  type        = string
  description = "Base64 encoded certificate data required to communicate with the cluster."
}
variable "cluster_endpoint" {
  type        = string
  description = "Endpoint for your Kubernetes API server."
}
variable "vpc_id" {
  type        = string
  description = "ID da VPC onde o cluster EKS está localizado."
}
variable "alb_name" {
  type        = string
  description = "Nome do Application Load Balancer."

}

variable "oidc_provider" {
  type        = string
  description = "ARN do OIDC provider para o cluster EKS."
}

variable "group_name" {
  type        = string
  description = "Nome do grupo de load balancer onde será criado os ingress."

}
variable "namespace" {
  type        = string
  description = "Namespace onde o ALB Controller será instalado."

}

variable "alb-sg" {
  type        = string
  description = "ID do Security Group associado ao Application Load Balancer."
}

variable "public_subnets" {
  type        = list(string)
  description = "Lista de IDs de sub-redes públicas onde o Application Load Balancer será criado."
}