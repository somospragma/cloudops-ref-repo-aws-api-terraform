locals {
  variables = merge(var.api_template_vars, { account_id = data.aws_caller_identity.current.account_id })
}