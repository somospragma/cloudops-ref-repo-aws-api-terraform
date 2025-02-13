module "api_gateway" {
  source         = "./module/api_gateway"

  # Variables de nombramiento
  client        = var.client
  project       = var.project
  environment   = var.environment
  application   = var.application
  functionality = var.functionality
  aws_region    = var.aws_region

  # Categoria de la API REST
  endpoint_type        = var.endpoint_type

  # En caso de necesitar Cognito
  cognito_user_pool_arns = var.cognito_user_pool_arns

  # En caso de que sea privada
  private_api_vpce     = var.private_api_vpce
  vpc_link_description = var.vpc_link_description
  vpc_link_target_arns = var.vpc_link_target_arns
  
  #configuración principal
  resources = var.resources
}
