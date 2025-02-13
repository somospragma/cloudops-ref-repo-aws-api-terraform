output "rest_api_id" {
  description = "ID del API Gateway"
  value       = aws_api_gateway_rest_api.this.id
}

output "invoke_url" {
  description = "URL para invocar el API Gateway (incluye el stage)"
  value       = aws_api_gateway_deployment.this.invoke_url
}

output "vpc_link_id" {
  description = "ID del VPC Link creado (si existe)"
  value       = local.has_vpc_methods ? aws_api_gateway_vpc_link.this[0].id : ""
}