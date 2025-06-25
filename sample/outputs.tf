output "rest_api_id" {
  description = "ID del API Gateway"
  value       = module.api.rest_api_id
}

output "invoke_url" {
  description = "URL para invocar el API Gateway (incluye el stage)"
  value       = module.api.invoke_url
}