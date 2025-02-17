# **🚀 Módulo Terraform para API Gateway: cloudops-ref-repo-aws-api-terraform**

## Descripción:

Este módulo facilita la creación de un API GATEWAY tipo REST para tres configuraciones "REGIONAL", "PRIVATE" y "EDGE", con el uso opcional de "COGNITO" como autorizador, el cual requiere de los siguientes recursos, los cuales debieron ser previamente creados:

- cognito_user_pool_arns: ARN del user pool (En caso de ponerle como autorizador el "COGNITO".
- private_api_vpce      : ID del VPCE (En caso de ser "PRIVATE").
- vpc_link_target_arns  : ARN del NLB para ser asociado al VPCLINK (En caso de ser "PRIVATE").
- lambda_function_arn   : ARN de lambda (Sí el metodo de integración es LAMBDA, se incluye dentro de la variable "resource")
- http_uri              : Dirección de consumo del metodo de la API (Sí el metodo de integración es VPC o HTTP, se incluye dentro de la variable "resource")

Consulta CHANGELOG.md para la lista de cambios de cada versión. *Recomendamos encarecidamente que en tu código fijes la versión exacta que estás utilizando para que tu infraestructura permanezca estable y actualices las versiones de manera sistemática para evitar sorpresas.*

## Estructura del Módulo

El módulo cuenta con la siguiente estructura:

```bash
cloudops-ref-repo-aws-rds-terraform/
└── sample/
    ├── data.tf
    ├── main.tf
    ├── outputs.tf
    ├── providers.tf
    ├── terraform.auto.tfvars
    └── variables.tf
├── CHANGELOG.md
├── README.md
├── data.tf
├── locals.tf
├── main.tf
├── outputs.tf
├── variables.tf
```

- Los archivos principales del módulo (`data.tf`, `main.tf`, `outputs.tf`, `variables.tf`, `locals.tf`) se encuentran en el directorio raíz.
- `CHANGELOG.md` y `README.md` también están en el directorio raíz para fácil acceso.
- La carpeta `sample/` contiene un ejemplo de implementación del módulo.


## Uso del Módulo:

```hcl
module "api_gateway" {
  source         = "./module/api_gateway"

  # Variables de nombramiento
  client        = "xxxxxx"
  project       = "xxxxxx"
  environment   = "xxxxxx"
  application   = "xxxxxx"
  functionality = "xxxxxx"
  aws_region    = "xxxxxx"

  # Categoria de la API REST
  endpoint_type        = "xxxxxx"   (PRIVATE, REGIONAL o EDGE)

  # En caso de necesitar Cognito
  cognito_user_pool_arns = ["xxxxxx"]

  # En caso de que sea privada
  private_api_vpce     = "xxxxxx"
  vpc_link_description = "xxxxxx"
  vpc_link_target_arns = ["xxxxx"]
  
  #configuración principal
  resources = [{ xxx=.... }]
}
```
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.13.1 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.31.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws.project"></a> [aws.project](#provider\_aws) | >= 4.31.0 |

## Resources

| Name | Type |
|------|------|
| [aws_api_gateway_rest_api.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_rest_api) | resource |
| [aws_api_gateway_resource.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_resource) | resource |
| [aws_api_gateway_vpc_link.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_vpc_link) | resource |
| [aws_api_gateway_authorizer.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_authorizer) | resource |
| [aws_api_gateway_method.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_method) | resource |
| [aws_api_gateway_integration.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_integration) | resource |
| [aws_api_gateway_deployment.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_deployment) | resource |
| [aws_api_gateway_rest_api_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_rest_api_policy) | resource |
| [aws_iam_role_policy.apigw_lambda_invoke_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role.apigw_lambda_invoke](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |

## 📌 Variables

### 🔹 Configuración General

| Nombre          | Tipo   | Descripción |
|----------------|--------|-------------|
| `client`       | string | Nombre del cliente. |
| `environment`  | string | Entorno de despliegue (dev, staging, prod, etc.). |
| `project`      | string | Nombre del proyecto. |
| `functionality`| string | Funcionalidad específica dentro del proyecto. |
| `application`  | string | Nombre de la aplicación asociada al API Gateway. |
| `aws_region`   | string | Región de AWS donde se desplegará la infraestructura. |

### 🔹 Configuración del API Gateway

| Nombre            | Tipo   | Descripción |
|-------------------|--------|-------------|
| `endpoint_type`   | string | Tipo de endpoint del API Gateway: `PRIVATE`, `REGIONAL` o `EDGE`. Predeterminado: `REGIONAL`. |
| `private_api_vpce` | string | ID del VPC Endpoint autorizado para acceder a la API privada. Requerido si `endpoint_type` es `PRIVATE`. |

### 🔹 Definición de Recursos y Métodos

| Nombre       | Tipo | Descripción |
|-------------|------|-------------|
| `resources` | list(object) | Lista de recursos y sus métodos en el API Gateway. Cada recurso debe incluir:
  - `resource_name` (string): Nombre del recurso.
  - `path_part` (string): Parte de la ruta del recurso.
  - `methods` (list): Métodos HTTP soportados con:
    - `http_method` (string): Método HTTP (`GET`, `POST`, etc.).
    - `authorization` (string): Tipo de autorización (`NONE`, `COGNITO_USER_POOLS`, etc.).
    - `integration_type` (string): Tipo de integración (`LAMBDA`, `HTTP`, `VPC`).
    - `lambda_function_arn` (string, opcional): ARN de la función Lambda si `integration_type` es `LAMBDA`.
    - `http_uri` (string, opcional): URI de destino si `integration_type` es `HTTP`. |

### 🔹 Configuración de VPC Link

| Nombre                  | Tipo        | Descripción |
|-------------------------|------------|-------------|
| `vpc_link_description`  | string     | Descripción del VPC Link. Predeterminado: `VPC Link para automatico`. |
| `vpc_link_target_arns`  | list(string) | Lista de ARNs de los Network Load Balancers (o endpoints) para el VPC Link. |

### 🔹 Configuración de Cognito

| Nombre                   | Tipo        | Descripción |
|--------------------------|------------|-------------|
| `cognito_user_pool_arns` | list(string) | Lista de ARNs de los User Pools de Cognito para autenticación. |
| `cognito_authorizer_name` | string     | Nombre del autorizador de Cognito. Predeterminado: `CognitoAuthorizer`. |
| `cognito_identity_source` | string     | Origen de la identidad, generalmente el header de autorización. Predeterminado: `method.request.header.Authorization`. |

### 📤 Outputs

| Nombre  | Descripción |
|--------------------------|-------------|
| rest_api_id | ID del API Gateway.
|invoke_url | URL para invocar el API Gateway (incluye el stage).
|vpc_link_id| ID del VPC Link creado (si existe).

