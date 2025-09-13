#========================================================================================#
#                                 CUSTOMER VARIABLES                                     #
#========================================================================================#

variable "prefix_name" {
  description = "Prefix for resource names"
  type        = string
}

variable "environment_name" {
  type        = string
  description = "Environment name where API Gateway will be provisioned. Allowed values: [prd | stg | qa | dev | labs | payer | devops]"
  validation {
    condition     = contains(["prd", "stg", "qa", "dev", "labs", "payer", "devops"], var.environment_name)
    error_message = "Value must be 'prd', 'stg', 'qa', 'dev' or 'labs'."
  }
}

#========================================================================================#
#                                 API GATEWAY VARIABLES                                  #
#========================================================================================#

variable "cors_configuration" {
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

variable "throttle_settings" {
  description = "Throttling settings"
  type = object({
    burst_limit = optional(number, 5000)
    rate_limit  = optional(number, 10000)
  })
  default = {}
}

variable "lambda_invoke_arn" {
  description = "Lambda function invoke ARN for API Gateway integration"
  type        = string
}