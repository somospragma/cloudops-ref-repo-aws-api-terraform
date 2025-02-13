variable "client" {
  type = string
}

variable "environment" {
  type = string
}

variable "project" {
  type = string  
}

variable "functionality" {
  type = string  
}

variable "application" {
  type = string  
}

variable "aws_region" {
  type = string
}

variable "endpoint_type" {
  description = "Tipo de endpoint del API Gateway: PRIVATE, REGIONAL o EDGE"
  type        = string
  default     = "REGIONAL"
}

variable "resources" {
  description = "Lista de recursos y sus métodos para el API Gateway. Cada recurso es un objeto con: resource_name, path_part y methods."
  type = list(object({
    resource_name = string
    path_part     = string
    methods       = list(object({
      http_method         = string
      authorization       = string
      integration_type    = string   # Valores válidos: "LAMBDA", "HTTP" o "VPC"
      lambda_function_arn = optional(string)
      http_uri            = optional(string)
    }))
  }))
}

variable "vpc_link_description" {
  description = "Descripción del VPC Link"
  type        = string
  default     = "VPC Link para automatico"
}

variable "vpc_link_target_arns" {
  description = "Lista de ARNs de los Network Load Balancers (u otros endpoints) para el VPC Link"
  type        = list(string)
  default     = []
}

variable "private_api_vpce" {
  description = "ID del VPC Endpoint autorizado para acceder a la API privada"
  type        = string
  # Debes asignar un valor si usas endpoint_type = "PRIVATE"
}

variable "cognito_user_pool_arns" {
  description = "Lista de ARNs de los User Pools de Cognito para la autorización"
  type        = list(string)
  default     = []
}

variable "cognito_authorizer_name" {
  description = "Nombre del authorizer de Cognito"
  type        = string
  default     = "CognitoAuthorizer"
}

variable "cognito_identity_source" {
  description = "Origen de la identidad, por lo general el header de autorización"
  type        = string
  default     = "method.request.header.Authorization"
}