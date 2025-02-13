locals {
  methods = { for m in flatten([
    for res in var.resources : [
      for method in res.methods : {
        key                 = "${res.resource_name}-${upper(method.http_method)}-${upper(method.integration_type)}"
        resource_name       = res.resource_name
        http_method         = upper(method.http_method)
        authorization       = method.authorization
        integration_type    = upper(method.integration_type)
        lambda_function_arn = lookup(method, "lambda_function_arn", "")
        http_uri            = lookup(method, "http_uri", "")
      }
    ]
  ]) : m.key => m }

  # Determina si existe al menos un método con integración VPC
  has_vpc_methods = length([for m in local.methods : m if m.integration_type == "VPC"]) > 0
}