variable "cidr_block" {
  description = "O bloco CIDR principal da VPC (ex: 10.0.0.0/16)"
  type        = string
  default     = "10.0.0.0/16"
}

variable "number_of_azs" {
  description = "Número de Zonas de Disponibilidade (AZs) para criar subnets."
  type        = number
  default     = 2
  validation {
    condition     = var.number_of_azs > 0 && var.number_of_azs <= 6
    error_message = "O número de AZs deve ser entre 1 e 6."
  }
}

variable "create_app_subnets" {
  description = "Habilita a criação de subnets privadas com rota para NAT Gateway."
  type        = bool
  default     = true
}

variable "create_data_subnets" {
  description = "Habilita a criação de subnets privadas com rotas internas."
  type        = bool
  default     = true
}

variable "eks_cluster_name" {
  description = "Utilizado para o calculo de barramento da subnet."
  type        = string
  default     = ""
}