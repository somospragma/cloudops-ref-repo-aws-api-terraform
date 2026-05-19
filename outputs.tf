output "rest_api_id" {
  description = "ID del API Gateway"
  value       = aws_api_gateway_rest_api.this.id
}

output "invoke_url" {
  description = "URL para invocar el API Gateway (incluye el stage)"
  value       = aws_api_gateway_stage.stage.invoke_url
}

output "stage_arn" {
  description = "Stage ARN"
  value       = aws_api_gateway_stage.stage.arn
}

output "custom_domain_name" {
  description = "Custom domain name"
  value       = var.custom_domain_name != null ? aws_api_gateway_domain_name.this[0].domain_name : null
}

output "domain_name_target" {
  description = "Target domain name for DNS configuration"
  value       = var.custom_domain_name != null ? aws_api_gateway_domain_name.this[0].cloudfront_domain_name : null
}

######################################################################
# API Keys y Usage Plans Outputs (PC-IAC-007, PC-IAC-014)
######################################################################
output "api_keys" {
  description = "Mapa de API Keys creados con sus atributos"
  value = {
    for key, api_key in aws_api_gateway_api_key.this : key => {
      id   = api_key.id
      name = api_key.name
      arn  = api_key.arn
    }
  }
}

output "api_key_values" {
  description = "Valores de los API Keys (sensible)"
  value = {
    for key, api_key in aws_api_gateway_api_key.this : key => api_key.value
  }
  sensitive = true
}

output "usage_plans" {
  description = "Mapa de Usage Plans creados con sus atributos"
  value = {
    for key, plan in aws_api_gateway_usage_plan.this : key => {
      id   = plan.id
      name = plan.name
      arn  = plan.arn
    }
  }
}