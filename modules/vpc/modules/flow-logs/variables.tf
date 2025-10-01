variable "prefix_name" {
  type        = string
  description = "Prefix name to be used on naming resources"

}

variable "environment" {
  description = "Name to give the VPC Flow Logs"
  type        = string
}


variable "vpc_id" {
  description = "VPC ID to create flow logs for."
  type        = string
}

variable "tags" {
  description = "Tags."
  type        = map(string)
  default     = null
}