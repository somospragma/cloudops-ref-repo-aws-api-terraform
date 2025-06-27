module "api" {
  source = "../"
  
  providers = {
    aws.project = aws.project
  }
  
  aws_region        = var.aws_region
  environment       = var.environment
  common_tags       = var.common_tags

  client            = var.client
  project           = var.project
  application       = var.application 
  functionality     = var.functionality

  lambda_name       = var.lambda_name
  stage_name        = var.stage_name
  api_template      = var.api_template
  api_template_vars = var.api_template_vars
  endpoint_type     = var.endpoint_type
  private_api_vpce  = var.private_api_vpce
}