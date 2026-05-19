# Crea el API Gateway con el tipo de endpoint seleccionado
resource "aws_api_gateway_rest_api" "this" {
  provider    = aws.project
  name        = "${var.project}-${var.client}-${var.environment}-api-${var.application}-${var.functionality}"
  description = "API Gateway"
  body        = data.template_file.api_template.rendered

  endpoint_configuration {
    types            = [upper(var.endpoint_type)]
    vpc_endpoint_ids = upper(var.endpoint_type) == "PRIVATE" ? [var.private_api_vpce] : null
  }
}

# Despliega el API Gateway en un stage
resource "aws_api_gateway_deployment" "this" {
  provider    = aws.project
  rest_api_id = aws_api_gateway_rest_api.this.id

  triggers = {
    # Solo redespliega cuando cambia la definición del API
    redeployment = sha1(jsonencode(aws_api_gateway_rest_api.this.body))
  }

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [aws_api_gateway_rest_api.this]
}

resource "aws_api_gateway_stage" "stage" {
  provider      = aws.project
  deployment_id = aws_api_gateway_deployment.this.id
  rest_api_id   = aws_api_gateway_rest_api.this.id
  stage_name    = var.stage_name

  tags = merge(
    var.common_tags,
    { Name = "${var.project}-${var.client}-${var.environment}-api-${var.application}-${var.functionality}" },
  )
}

# Custom Domain Name
resource "aws_api_gateway_domain_name" "this" {
  count                    = var.custom_domain_name != null ? 1 : 0
  provider                 = aws.project
  domain_name              = var.custom_domain_name
  certificate_arn          = upper(var.endpoint_type) == "EDGE" ? var.certificate_arn : null
  regional_certificate_arn = upper(var.endpoint_type) == "REGIONAL" ? var.certificate_arn : null

  endpoint_configuration {
    types = [upper(var.endpoint_type)]
  }

  tags = merge(
    var.common_tags,
    { Name = "${var.project}-${var.client}-${var.environment}-api-${var.application}-${var.functionality}-domain" },
  )
}

# Base Path Mapping
resource "aws_api_gateway_base_path_mapping" "this" {
  count       = var.custom_domain_name != null ? 1 : 0
  provider    = aws.project
  api_id      = aws_api_gateway_rest_api.this.id
  stage_name  = aws_api_gateway_stage.stage.stage_name
  domain_name = aws_api_gateway_domain_name.this[0].domain_name
}

######################################################################
# API Keys y Usage Plans (PC-IAC-010: for_each obligatorio)
######################################################################

# API Keys
resource "aws_api_gateway_api_key" "this" {
  for_each = var.api_keys
  provider = aws.project

  name        = "${var.project}-${var.client}-${var.environment}-apikey-${var.application}-${each.key}"
  description = each.value.description
  enabled     = each.value.enabled

  tags = merge(
    var.common_tags,
    { Name = "${var.project}-${var.client}-${var.environment}-apikey-${var.application}-${each.key}" },
  )
}

# Usage Plans (uno por cada API Key)
resource "aws_api_gateway_usage_plan" "this" {
  for_each = var.api_keys
  provider = aws.project

  name = "${var.project}-${var.client}-${var.environment}-usageplan-${var.application}-${each.key}"

  api_stages {
    api_id = aws_api_gateway_rest_api.this.id
    stage  = aws_api_gateway_stage.stage.stage_name
  }

  throttle_settings {
    rate_limit  = each.value.rate_limit
    burst_limit = each.value.burst_limit
  }

  quota_settings {
    limit  = each.value.quota_limit
    period = each.value.quota_period
  }

  tags = merge(
    var.common_tags,
    { Name = "${var.project}-${var.client}-${var.environment}-usageplan-${var.application}-${each.key}" },
  )

  depends_on = [aws_api_gateway_stage.stage]
}

# Asociación API Key con Usage Plan
resource "aws_api_gateway_usage_plan_key" "this" {
  for_each = var.api_keys
  provider = aws.project

  key_id        = aws_api_gateway_api_key.this[each.key].id
  key_type      = "API_KEY"
  usage_plan_id = aws_api_gateway_usage_plan.this[each.key].id
}
