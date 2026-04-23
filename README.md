# Módulo de Referencia - API Gateway REST

Módulo de Terraform para la creación y gestión de Amazon API Gateway REST API, siguiendo las reglas de gobernanza PC-IAC.

## Descripción

Este módulo crea un API Gateway REST con las siguientes capacidades:

- Definición de la API mediante template Swagger/OpenAPI en base64
- Soporte para endpoints **REGIONAL**, **EDGE** y **PRIVATE**
- Deployment automático con stage configurable
- Custom Domain Name con certificado ACM (opcional)
- Base Path Mapping al stage (opcional)
- Nomenclatura construida internamente: `{project}-{client}-{environment}-api-{application}-{functionality}`

## Uso Básico

```hcl
module "api" {
  source = "git::https://github.com/somospragma/cloudops-ref-repo-aws-api-terraform.git?ref=v1.0.0"

  providers = {
    aws.project = aws.principal
  }

  aws_region    = var.aws_region
  environment   = var.environment
  common_tags   = var.common_tags
  client        = var.client
  project       = var.project
  application   = var.application
  functionality = var.functionality

  lambda_name       = var.lambda_name
  stage_name        = var.stage_name
  api_template      = var.api_template
  api_template_vars = var.api_template_vars
  endpoint_type     = var.endpoint_type
  private_api_vpce  = var.private_api_vpce
}
```

## Ejemplos

### 1. API Regional con integración Lambda (proxy)

```hcl
# terraform.tfvars
lambda_name       = "orders-api"
stage_name        = "v1"
endpoint_type     = "REGIONAL"
private_api_vpce  = null

api_template_vars = {
  stage_name = "v1"
}

# api_template: Swagger en base64 con integración aws_proxy a Lambda.
# El template recibe automáticamente las variables: api_name, aws_region, account_id, lambda_function_name.
```

El template Swagger debe estar codificado en base64 y contener las integraciones `x-amazon-apigateway-integration`. Ejemplo de template antes de codificar:

```json
{
  "swagger": "2.0",
  "info": {
    "title": "${api_name}",
    "version": "1.0"
  },
  "paths": {
    "/hello": {
      "get": {
        "responses": {
          "200": { "description": "OK" }
        },
        "x-amazon-apigateway-integration": {
          "type": "aws_proxy",
          "httpMethod": "POST",
          "uri": "arn:aws:apigateway:${aws_region}:lambda:path/2015-03-31/functions/arn:aws:lambda:${aws_region}:${account_id}:function:${lambda_function_name}/invocations",
          "responses": {
            "default": { "statusCode": "200" }
          }
        }
      }
    }
  }
}
```

### 2. API con endpoint PRIVATE (VPC Endpoint)

```hcl
# terraform.tfvars
endpoint_type    = "PRIVATE"
private_api_vpce = "vpce-0123456789abcdef0"
```

> El VPC Endpoint debe ser de tipo `execute-api` y estar en la misma región que el API Gateway.

### 3. API con Custom Domain Name (REGIONAL)

```hcl
# terraform.tfvars
endpoint_type      = "REGIONAL"
custom_domain_name = "api.example.com"
certificate_arn    = "arn:aws:acm:us-east-1:123456789012:certificate/abc-123"
```

### 4. API con Custom Domain Name (EDGE)

```hcl
# terraform.tfvars
endpoint_type      = "EDGE"
custom_domain_name = "api.example.com"
certificate_arn    = "arn:aws:acm:us-east-1:123456789012:certificate/abc-123"
```

> Para endpoints EDGE, el certificado ACM debe estar en `us-east-1`. Para REGIONAL, debe estar en la misma región del API Gateway.


### 5. Variables del template Swagger

El módulo inyecta automáticamente las siguientes variables al template Swagger a través de `locals.tf`:

| Variable | Origen | Descripción |
|---|---|---|
| `api_name` | Construida | `{project}-{client}-{environment}-api-{application}-{functionality}` |
| `aws_region` | `var.aws_region` | Región AWS del despliegue |
| `account_id` | `data.aws_caller_identity` | ID de la cuenta AWS |
| `lambda_function_name` | Construida | `{client}-{project}-{environment}-{lambda_name}` |

Además, cualquier variable adicional pasada en `api_template_vars` se fusiona con las anteriores mediante `merge()`.

## Inputs

| Nombre | Tipo | Requerido | Default | Descripción |
|---|---|---|---|---|
| `aws_region` | `string` | Sí | — | Región AWS para el despliegue |
| `environment` | `string` | Sí | — | Entorno: `dev`, `qa`, `pdn` |
| `client` | `string` | Sí | — | Nombre del cliente |
| `project` | `string` | Sí | — | Nombre del proyecto |
| `application` | `string` | Sí | — | Nombre de la aplicación |
| `functionality` | `string` | Sí | — | Funcionalidad de la API |
| `common_tags` | `map(string)` | Sí | — | Tags comunes para todos los recursos |
| `lambda_name` | `string` | Sí | — | Nombre de la función Lambda (se usa para construir el nombre completo) |
| `stage_name` | `string` | Sí | — | Nombre del stage del API Gateway (ej: `v1`) |
| `api_template` | `string` | Sí | — | Template Swagger/OpenAPI codificado en base64 |
| `api_template_vars` | `map(string)` | Sí | — | Variables adicionales para el template Swagger |
| `endpoint_type` | `string` | No | `"REGIONAL"` | Tipo de endpoint: `PRIVATE`, `REGIONAL` o `EDGE` |
| `private_api_vpce` | `string` | No* | — | ID del VPC Endpoint para APIs privadas. *Requerido si `endpoint_type = "PRIVATE"` |
| `custom_domain_name` | `string` | No | `null` | Nombre de dominio personalizado |
| `certificate_arn` | `string` | No | `null` | ARN del certificado ACM para el dominio personalizado |

## Outputs

| Nombre | Tipo | Descripción |
|---|---|---|
| `rest_api_id` | `string` | ID del API Gateway REST |
| `invoke_url` | `string` | URL de invocación del API Gateway (incluye el stage) |
| `stage_arn` | `string` | ARN del stage |
| `custom_domain_name` | `string` | Nombre del dominio personalizado (null si no se configuró) |
| `domain_name_target` | `string` | Dominio destino para configuración DNS (CloudFront o regional, según endpoint) |

## Requisitos

| Nombre | Versión |
|---|---|
| Terraform | `>= 1.0.0` |
| AWS Provider | `>= 4.31.0` |
| Template Provider | `~> 2.2` |

## Provider

El módulo requiere el alias `aws.project` inyectado desde el Root (PC-IAC-005):

```hcl
providers = {
  aws.project = aws.principal
}
```

## Nomenclatura

El nombre del API Gateway se construye automáticamente en `main.tf`:

```
{project}-{client}-{environment}-api-{application}-{functionality}
```

El nombre de la función Lambda referenciada se construye en `locals.tf`:

```
{client}-{project}-{environment}-{lambda_name}
```

## Cumplimiento de Reglas PC-IAC

| Regla | Descripción | Implementación |
|---|---|---|
| PC-IAC-001 | Estructura de Módulo | 7 archivos raíz + 8 archivos en `sample/` |
| PC-IAC-002 | Variables | Variables tipadas con descripciones y defaults donde aplica |
| PC-IAC-003 | Nomenclatura | Nombre construido en `main.tf`: `{project}-{client}-{env}-api-{app}-{func}` |
| PC-IAC-004 | Tagging | `merge()` de `common_tags` + `Name` en cada recurso |
| PC-IAC-005 | Providers | Alias `aws.project` con `provider = aws.project` explícito |
| PC-IAC-007 | Outputs | Granulares: `rest_api_id`, `invoke_url`, `stage_arn`, dominio |
| PC-IAC-023 | Responsabilidad Única | Solo recursos intrínsecos a API Gateway (REST API, deployment, stage, domain) |
| PC-IAC-026 | Patrón sample/ | `tfvars` → `data.tf` → `locals.tf` → `main.tf` → `../` |

## Decisiones de Diseño

- **Template Swagger en base64:** La definición de la API se pasa como string base64 para permitir flexibilidad total en la estructura del Swagger/OpenAPI. El módulo decodifica y renderiza las variables automáticamente usando `data.template_file`.

- **Variables inyectadas automáticamente:** El módulo construye `api_name`, `aws_region`, `account_id` y `lambda_function_name` internamente y las fusiona con `api_template_vars`, simplificando el uso desde el Root.

- **Redeployment automático:** El deployment usa `triggers = { redeployment = timestamp() }` para forzar un nuevo despliegue en cada `terraform apply`, garantizando que los cambios en el template se reflejen inmediatamente.

- **Custom Domain opcional:** Los recursos de dominio personalizado (`aws_api_gateway_domain_name` y `aws_api_gateway_base_path_mapping`) se crean condicionalmente solo cuando `custom_domain_name != null`.

- **Sin creación de certificados ACM ni registros DNS:** Siguiendo PC-IAC-023, el módulo no crea recursos de seguridad ni DNS. Los ARNs de certificados se reciben como variables de entrada y la configuración DNS es responsabilidad del consumidor.

- **Soporte multi-endpoint:** El módulo soporta los tres tipos de endpoint de API Gateway (REGIONAL, EDGE, PRIVATE) mediante una sola variable, adaptando automáticamente la configuración de VPC Endpoints y certificados.

---

> Este módulo ha sido desarrollado siguiendo los estándares de Pragma CloudOps, garantizando una implementación segura, escalable y optimizada que cumple con todas las políticas de la organización. Pragma CloudOps recomienda revisar este código con su equipo de infraestructura antes de implementarlo en producción.

## Licencia

Copyright © 2026 Pragma S.A. Todos los derechos reservados.
