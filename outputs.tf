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