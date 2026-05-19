locals {
  # Prefijo de gobernanza (PC-IAC-003)
  governance_prefix = "${var.client}-${var.project}-${var.environment}"

  # Nomenclaturas de recursos
  api_name    = "${local.governance_prefix}-api-${var.application}-${var.functionality}"
  domain_name = "${local.governance_prefix}-api-${var.application}-${var.functionality}-domain"

  # Variables para el template OpenAPI
  variables = merge(var.api_template_vars, {
    api_name             = local.api_name
    aws_region           = var.aws_region
    account_id           = data.aws_caller_identity.current.account_id
    lambda_function_name = "${local.governance_prefix}-lambda-${var.lambda_name}"
  })

  base64_api_template = split("base64,", var.api_template)[1]

  # Nomenclaturas para API Keys y Usage Plans (PC-IAC-012)
  api_keys_config = {
    for key, config in var.api_keys : key => merge(config, {
      apikey_name    = "${local.governance_prefix}-apikey-${key}"
      usageplan_name = "${local.governance_prefix}-usageplan-${key}"
    })
  }
}