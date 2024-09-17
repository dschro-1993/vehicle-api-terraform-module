locals {
# api_prefix = if var.env == "prod" ? "" : var.env
}

resource "aws_api_gateway_rest_api" "rest_api" {
  name = "${var.app_name}-${var.env}"
  endpoint_configuration { types = ["REGIONAL"] }
}

resource "aws_api_gateway_resource" "my_proxy" {
  rest_api_id = aws_api_gateway_rest_api.rest_api.id
  parent_id   = aws_api_gateway_rest_api.rest_api.root_resource_id
  path_part   = "{proxy+}"
}

resource "aws_api_gateway_method" "any" {
  authorization = "NONE" # Todo => Add Cognito-Authorizer here!

  rest_api_id = aws_api_gateway_rest_api.rest_api.id
  resource_id = aws_api_gateway_resource.my_proxy.id

  http_method = "ANY"
}

resource "aws_api_gateway_integration" "any" {
  http_method = "ANY"

  depends_on = [aws_api_gateway_method.any]

  rest_api_id = aws_api_gateway_rest_api.rest_api.id
  resource_id = aws_api_gateway_resource.my_proxy.id

  integration_http_method = "POST" # Is required if type is: AWS_PROXY
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.api_handler.invoke_arn
}

# ---

resource "aws_api_gateway_deployment" "deployment" {
  triggers    = { redeployment = sha256(jsonencode(aws_api_gateway_rest_api.rest_api.body)) }
  rest_api_id = aws_api_gateway_rest_api.rest_api.id
  lifecycle { create_before_destroy = true }
}

# resource "aws_cloudwatch_log_group" "access_logging" {
#   name              = "${var.app_name}-${var.env}-access-logging"
#   retention_in_days = 100
# }

resource "aws_api_gateway_stage" "stage" {
  deployment_id = aws_api_gateway_deployment.deployment.id

  rest_api_id = aws_api_gateway_rest_api.rest_api.id
  stage_name  = "api" # Todo => Add Env-Variable

  xray_tracing_enabled = !false

# dynamic "access_log_settings" {
#   for_each = var.api_gateway_access_logging_enabled ? [1] : []
#   content {
#     destination_arn = aws_cloudwatch_log_group.access_logging.arn
#     format          = "{...}"
#   }
# }
}

# ---

resource "aws_api_gateway_domain_name" "domain_name" {
  endpoint_configuration { types = ["REGIONAL"] }
  domain_name              = "${var.app_name}-${var.env}.${var.zone_name}"
  regional_certificate_arn = aws_acm_certificate_validation.certificate_validation.certificate_arn
}

resource "aws_route53_record" "alias_record" {
  alias {
    evaluate_target_health = false
    name                   = aws_api_gateway_domain_name.domain_name.regional_domain_name
    zone_id                = aws_api_gateway_domain_name.domain_name.regional_zone_id
  }
  name    = aws_api_gateway_domain_name.domain_name.domain_name
  zone_id = data.aws_route53_zone.public.zone_id
  type    = "A"
}

resource "aws_api_gateway_base_path_mapping" "mapping" {
  domain_name = aws_api_gateway_domain_name.domain_name.domain_name
  stage_name  = aws_api_gateway_stage.stage.stage_name

  api_id = aws_api_gateway_rest_api.rest_api.id
}

# {...}
