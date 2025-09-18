#========================================================================================#
#                                 CUSTOMER VARIABLES                                     #
#========================================================================================#

variable "prefix_name" {
  description = "Prefix for resource names"
  type        = string
}

variable "environment_name" {
  type        = string
  description = "Environment name where FSx OpenZFS will be provisioned. Allowed values: [prd | stg | qa | dev | labs | payer | devops]"
  validation {
    condition     = contains(["prd", "stg", "qa", "dev", "labs", "payer", "devops"], var.environment_name)
    error_message = "Value must be 'prd', 'stg', 'qa', 'dev' or 'labs'."
  }
}

#========================================================================================#
#                                FSX OPENZFS VARIABLES                                  #
#========================================================================================#

variable "subnet_ids" {
  description = "List of subnet IDs for FSx OpenZFS"
  type        = list(string)
}

variable "vpc_id" {
  description = "VPC ID where FSx OpenZFS will be deployed"
  type        = string
}

variable "security_group_ids" {
  description = "List of security group IDs for FSx OpenZFS"
  type        = list(string)
  default     = []
}

variable "storage_capacity" {
  description = "Storage capacity in GiB"
  type        = number
  default     = 64
}

variable "throughput_capacity" {
  description = "Throughput capacity in MBps"
  type        = number
  default     = 64
}

variable "deployment_type" {
  description = "Deployment type for FSx OpenZFS"
  type        = string
  default     = "SINGLE_AZ_1"
}

variable "automatic_backup_retention_days" {
  description = "Number of days to retain automatic backups"
  type        = number
  default     = 7
}

variable "copy_tags_to_backups" {
  description = "Copy tags to backups"
  type        = bool
  default     = true
}

variable "copy_tags_to_volumes" {
  description = "Copy tags to volumes"
  type        = bool
  default     = true
}