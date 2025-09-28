#========================================================================================#
#                                 CUSTOMER VARIABLES                                     #
#========================================================================================#

variable "prefix_name" {
  description = "Prefix for resource names"
  type        = string
}

variable "environment_name" {
  type        = string
  description = "Environment name where Lambda will be provisioned. Allowed values: [prd | stg | qa | dev | labs | payer | devops]"
  validation {
    condition     = contains(["prd", "stg", "qa", "dev", "labs", "payer", "devops"], var.environment_name)
    error_message = "Value must be 'prd', 'stg', 'qa', 'dev' or 'labs'."
  }
}

#========================================================================================#
#                                 LAMBDA VARIABLES                                       #
#========================================================================================#

variable "function_name" {
  description = "Name of the Lambda function"
  type        = string
  default     = "custom-authorizer"
}

variable "runtime" {
  description = "Lambda runtime"
  type        = string
  default     = "python3.11"
}

variable "handler" {
  description = "Lambda handler"
  type        = string
  default     = "index.lambda_handler"
}

variable "timeout" {
  description = "Lambda timeout in seconds"
  type        = number
  default     = 60
}

variable "environment_variables" {
  description = "Environment variables for Lambda"
  type        = map(string)
  default     = {}
}

