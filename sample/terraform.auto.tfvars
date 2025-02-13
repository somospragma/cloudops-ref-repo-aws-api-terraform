###############################################################
# Variables Globales
###############################################################


aws_region         = "us-east-1"
profile            = "pra_idp_dev"
environment        = "dev"
client             = "pragma"
project            = "hefesto"
functionality      = "sample"  
application        = "gateway"

common_tags = {
  environment   = "dev"
  project-name  = "Modulos Referencia"
  cost-center   = "-"
  owner         = "cristian.noguera@pragma.com.co"
  area          = "KCCC"
  provisioned   = "terraform"
  datatype      = "interno"
}


###############################################################
# Variables API GATEWAY
###############################################################

endpoint_type = "PRIVATE"
 
resources = [
        # Solo Regional o EDGE
        # {
        # resource_name = "users"
        # path_part     = "users"
        # methods = [
        #     {
        #     http_method         = "GET"
        #     authorization       = "NONE"
        #     integration_type    = "LAMBDA"
        #     lambda_function_arn = ""
        #     },
        #     {
        #     http_method      = "POST"
        #     authorization    = "NONE"
        #     integration_type = "HTTP"
        #     http_uri         = ""
        #     }
        # ]
        # }
        # Solo Privada
        {
        resource_name = "products"
        path_part     = "products"
        methods = [
            {
            http_method      = "GET"
            authorization    = "NONE"
            integration_type = "VPC"
            http_uri         = ""
            }
        ]
        }
    ]

cognito_user_pool_arns = []

vpc_link_target_arns = []

vpc_link_description = "VPC Link creado para integraciones VPC"

private_api_vpce = ""