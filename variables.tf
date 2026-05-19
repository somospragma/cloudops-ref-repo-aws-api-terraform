variable "common_tags" {
  type = map(string)
}

variable "aws_region" {
  type = string
}

variable "environment" {
  type = string
}

variable "client" {
  type = string
}

variable "project" {
  type = string
}

variable "application" {
  type = string
}

variable "functionality" {
  type = string
}

variable "lambda_name" {
  type = string
}

variable "stage_name" {
  type = string
}

variable "api_template" {
  description = "path of API template swagger file"
}

variable "api_template_vars" {
  description = "parameters for swagger file template"
}

variable "endpoint_type" {
  description = "Tipo de endpoint del API Gateway: PRIVATE, REGIONAL o EDGE"
  type        = string
  default     = "REGIONAL"
}

variable "private_api_vpce" {
  description = "ID del VPC Endpoint autorizado para acceder a la API privada"
  type        = string
  # Debes asignar un valor si usas endpoint_type = "PRIVATE"
}

variable "custom_domain_name" {
  description = "Custom domain name for API Gateway"
  type        = string
  default     = null
}

variable "certificate_arn" {
  description = "ACM certificate ARN for custom domain"
  type        = string
  default     = null
}

######################################################################
# API Keys y Usage Plans (PC-IAC-002, PC-IAC-009, PC-IAC-010)
######################################################################
variable "api_keys" {
  description = "Mapa de API Keys a crear. Cada key del mapa es el identificador único del API Key."
  type = map(object({
    enabled      = optional(bool, true)
    description  = optional(string, "")
    rate_limit   = optional(number, 10)
    burst_limit  = optional(number, 20)
    quota_limit  = optional(number, 50000)
    quota_period = optional(string, "MONTH")
  }))
  default = {}

  validation {
    condition = alltrue([
      for k, v in var.api_keys : contains(["DAY", "WEEK", "MONTH"], v.quota_period)
    ])
    error_message = "El quota_period debe ser: DAY, WEEK o MONTH."
  }
}