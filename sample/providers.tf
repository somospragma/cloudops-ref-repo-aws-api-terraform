######################################################################
# Provider AWS
######################################################################
provider "aws" {
  alias   = "principal"
  region  = var.aws_region
  profile = var.profile

  # Descomentar si vas a usar pipeline
  # assume_role {
  #   role_arn = var.deploy_role_arn
  # }

  default_tags {
    tags = var.common_tags
  }
}

######################################################################
# Definicion de versiones - Terraform - Providers
######################################################################
terraform {
  required_version = ">= 1.10.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">=4.31.0"
    }
  }
}