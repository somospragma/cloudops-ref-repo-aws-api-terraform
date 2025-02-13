# Crea el API Gateway con el tipo de endpoint seleccionado
resource "aws_api_gateway_rest_api" "this" {
  name        = "${var.project}-${var.client}-${var.environment}-api-${var.application}-${var.functionality}"
  description = "API Gateway Pragma"

  endpoint_configuration {
    types = [upper(var.endpoint_type)]
    vpc_endpoint_ids = upper(var.endpoint_type) == "PRIVATE" ? [var.private_api_vpce] : null

  }
}

# Crea los recursos (se asume que son hijos directos del recurso raíz)
resource "aws_api_gateway_resource" "this" {
  for_each  = { for res in var.resources : res.resource_name => res }
  rest_api_id = aws_api_gateway_rest_api.this.id
  parent_id   = aws_api_gateway_rest_api.this.root_resource_id
  path_part   = each.value.path_part
}

# Crea el VPC Link si existe algún método con integración VPC

resource "aws_api_gateway_vpc_link" "this" {
  count       = upper(var.endpoint_type) == "PRIVATE" ? 1 : 0
  name        = "${var.project}-${var.client}-${var.environment}-vpclink-${var.application}-${var.functionality}"
  description = var.vpc_link_description
  target_arns = var.vpc_link_target_arns
}

# Crea autorizador de cognito de ser necesario
resource "aws_api_gateway_authorizer" "this" {
  count       = length(var.cognito_user_pool_arns) > 0 ? 1 : 0
  name        = var.cognito_authorizer_name
  rest_api_id = aws_api_gateway_rest_api.this.id
  type        = "COGNITO_USER_POOLS"
  provider_arns = var.cognito_user_pool_arns
  identity_source = var.cognito_identity_source
}


# Crea role para la lambda en el integration type
resource "aws_iam_role" "apigw_lambda_invoke" {
  name = "apigw_lambda_invoke_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = "sts:AssumeRole",
        Principal = {
          Service = "apigateway.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "apigw_lambda_invoke_policy" {
  name = "apigw_lambda_invoke_policy"
  role = aws_iam_role.apigw_lambda_invoke.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = "lambda:InvokeFunction",
        Resource = "*"
      }
    ]
  })
}



# Crea los métodos para cada recurso
resource "aws_api_gateway_method" "this" {
  for_each = local.methods

  rest_api_id   = aws_api_gateway_rest_api.this.id
  resource_id   = aws_api_gateway_resource.this[each.value.resource_name].id
  http_method   = each.value.http_method
  authorization = each.value.authorization
  authorizer_id = (each.value.authorization == "COGNITO_USER_POOLS" && length(var.cognito_user_pool_arns) > 0) ? aws_api_gateway_authorizer.this[0].id : null
}

# Crea la integración para cada método, diferenciando entre Lambda, HTTP y VPC
resource "aws_api_gateway_integration" "this" {
  for_each = local.methods

  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.this[each.value.resource_name].id
  http_method = each.value.http_method
  integration_http_method = each.value.integration_type == "LAMBDA" ? "POST" : each.value.http_method
  type = each.value.integration_type == "LAMBDA" ? "AWS_PROXY" : "HTTP_PROXY"
  uri = each.value.integration_type == "LAMBDA" ? format("arn:aws:apigateway:%s:lambda:path/2015-03-31/functions/%s/invocations", var.aws_region, each.value.lambda_function_arn): each.value.http_uri

  # Role por si se escoge lambda como integration_type
  credentials = each.value.integration_type == "LAMBDA" ? aws_iam_role.apigw_lambda_invoke.arn : null

  # Para integraciones VPC se configura el VPC Link
  connection_type = each.value.integration_type == "VPC" ? "VPC_LINK" : null
  connection_id   = each.value.integration_type == "VPC" ? aws_api_gateway_vpc_link.this[0].id : null
}

# Despliega el API Gateway en un stage
resource "aws_api_gateway_deployment" "this" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  stage_name  = var.environment
  triggers = {
    redeployment = timestamp()
  }
  depends_on  = [aws_api_gateway_integration.this]
}


resource "aws_api_gateway_rest_api_policy" "this" {
  count       = upper(var.endpoint_type) == "PRIVATE" ? 1 : 0
  rest_api_id = aws_api_gateway_rest_api.this.id
  policy      = jsonencode({
    Version   = "2012-10-17",
    Statement = [
      {
        Effect    = "Allow",
        Principal = "*",
        Action    = "execute-api:Invoke",
        Resource  = "${aws_api_gateway_rest_api.this.execution_arn}/*",
        Condition = {
          StringEquals = {
            "aws:SourceVpce" = var.private_api_vpce
          }
        }
      }
    ]
  })
}
