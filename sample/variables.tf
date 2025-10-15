variable "profile" {
  type = string
}

# variable "deploy_role_arn" {
#   type = string
#   default = ""
# }

variable "aws_region" {
  type = string
}

variable "environment" {
  type = string
}

variable "common_tags" {
  type = map(string)
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
  default = "ewogICAgInN3YWdnZXIiOiAiMi4wIiwKICAgICJpbmZvIjogewogICAgICAidGl0bGUiOiAiJHthcGlfbmFtZX0iLAogICAgICAidmVyc2lvbiI6ICIxLjAiCiAgICB9LAogICAgInBhdGhzIjogewogICAgICAiL2hlbGxvIjogewogICAgICAgICJnZXQiOiB7CiAgICAgICAgICAicmVzcG9uc2VzIjogewogICAgICAgICAgICAiMjAwIjogewogICAgICAgICAgICAgICJkZXNjcmlwdGlvbiI6ICJPSyIKICAgICAgICAgICAgfQogICAgICAgICAgfSwKICAgICAgICAgICJ4LWFtYXpvbi1hcGlnYXRld2F5LWludGVncmF0aW9uIjogewogICAgICAgICAgICAidHlwZSI6ICJhd3NfcHJveHkiLAogICAgICAgICAgICAiaHR0cE1ldGhvZCI6ICJQT1NUIiwKICAgICAgICAgICAgInVyaSI6ICJhcm46YXdzOmFwaWdhdGV3YXk6JHthd3NfcmVnaW9ufTpsYW1iZGE6cGF0aC8yMDE1LTAzLTMxL2Z1bmN0aW9ucy9hcm46YXdzOmxhbWJkYToke2F3c19yZWdpb259OiR7YWNjb3VudF9pZH06ZnVuY3Rpb246JHtsYW1iZGFfZnVuY3Rpb25fbmFtZX0vaW52b2NhdGlvbnMiLAogICAgICAgICAgICAicmVzcG9uc2VzIjogewogICAgICAgICAgICAgICJkZWZhdWx0IjogewogICAgICAgICAgICAgICAgInN0YXR1c0NvZGUiOiAiMjAwIgogICAgICAgICAgICAgIH0KICAgICAgICAgICAgfQogICAgICAgICAgfQogICAgICAgIH0KICAgICAgfQogICAgfQogIH0="
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