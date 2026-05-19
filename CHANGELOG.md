# Changelog

Todos los cambios notables de este módulo serán documentados en este archivo.

El formato está basado en [Keep a Changelog](https://keepachangelog.com/es-ES/1.0.0/),
y este proyecto adhiere a [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.1.0] - 2025-05-19

### Added
- Soporte para **API Keys y Usage Plans** con configuración flexible mediante `map(object)` (PC-IAC-002, PC-IAC-010)
- Variable `api_keys` para definir múltiples API Keys con throttling y quotas individuales
- Recursos: `aws_api_gateway_api_key`, `aws_api_gateway_usage_plan`, `aws_api_gateway_usage_plan_key`
- Outputs: `api_keys`, `api_key_values` (sensible), `usage_plans`
- Nomenclatura automática para API Keys: `{project}-{client}-{environment}-apikey-{application}-{key}`
- Nomenclatura automática para Usage Plans: `{project}-{client}-{environment}-usageplan-{application}-{key}`

## [1.0.1] - 2025-05-15

### Fixed
- Cambio del trigger de deployment de `timestamp()` a `sha1(jsonencode(body))` para evitar redespliegues innecesarios

## [1.0.0] - 2025-05-10

### Added
- Versión inicial del módulo
- Soporte para endpoints REGIONAL, EDGE y PRIVATE
- Custom Domain Name con certificado ACM
- Base Path Mapping
- Template Swagger/OpenAPI en base64
- Cumplimiento de reglas PC-IAC
