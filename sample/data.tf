data "aws_caller_identity" "current" {
  provider = aws.principal
}

data "template_file" "api_template" {
  provider = aws.principal

  template = base64decode(locals.base64_api_template)
  vars     = local.variables
}