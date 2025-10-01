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

variable "default_region" {
  type    = string
  default = "us-east-1"
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
    max_age           = optional(number, 86400)
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

variable "lambda_function_arn" {
  description = "Lambda function ARN for API Gateway authorizer"
  type        = string
}

variable "vpc_subnet_ids" {
  description = "List of VPC subnet IDs for API Gateway VPC Link"
  type        = list(string)
}

variable "security_group_ids" {
  description = "List of security group IDs for API Gateway VPC Link"
  type        = list(string)
  default     = []
}

variable "eks_nlb_listener_arn" {
  description = "arn of the EKS NLB listener for API Gateway integration"
  type        = string
}

variable "open_routes" {
  type = list(string)
  default = [
    "POST /oauth/token",
    "POST /webhooks/payments/mercadoPago/callback",
  ]
}

variable "authorization_routes" {
  type = list(string)
  default = [
    "POST /customers",
    "GET /customers",
    "GET /customers/{customerId}",
    "PATCH /customers/{customerId}",
    "DELETE /customers/{customerId}",
    "GET /customers/listIds/{customerIdList}",
    "GET /customers/documentNumber/{documentNumber}",
    "PATCH /customers/documentNumber/{documentNumber}",
    "POST /customerOrders",
    "GET /customerOrder/{customerOrderId}",
    "GET /customerOrders/status/{statusList}",
    "PATCH /customerOrder/{customerOrderId}/updateStatus/{newStatus}",
    "POST /foodItems",
    "GET /foodItems",
    "GET /foodItems/{foodItemId}",
    "PATCH /foodItems/{foodItemId}",
    "DELETE /foodItems/{foodItemId}",
    "POST /foodItems/{foodItemId}/images",
    "GET /foodItems/{foodItemId}/images",
    "DELETE /foodItems/{foodItemId}/images",
    "GET /foodItems/image/{foodItemImageId}",
    "PUT /foodItems/image/{foodItemImageId}",
    "DELETE /foodItems/image/{foodItemImageId}",
    "POST /kitchenOrders",
    "GET /kitchenOrders",
    "GET /kitchenOrders/{kitchenOrderId}",
    "GET /kitchenOrders/status/{statusList}",
    "GET /kitchenOrders/customerOrder/{customerOrderId}",
    "PATCH /kitchenOrders/{kitchenOrderId}/updateStatus/{newStatus}",
    "GET /notifications",
    "GET /notifications/{notificationType}",
    "POST /payments/mercadoPago/charge",
    "PATCH /payments/mercadoPago/paymentReceived",
    "GET /payments/mercadoPago/customerOrder/{customerOrderId}/get",
    "PATCH /payments/mercadoPago/customerOrder/{customerOrderId}/cancel"
  ]
}





