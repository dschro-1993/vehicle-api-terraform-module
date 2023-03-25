resource "aws_api_gateway_rest_api" "rest_api" {
  name = "${var.app_name}-${var.env}"
  body = templatefile(var.openapi_spec_path, { uri = aws_lambda_function.api_resolver.invoke_arn }) # Todo
  endpoint_configuration { types = ["REGIONAL"] }
}

resource "aws_api_gateway_deployment" "deployment" {
  triggers    = { redeployment = sha1(jsonencode(aws_api_gateway_rest_api.rest_api.body)) }
  rest_api_id = aws_api_gateway_rest_api.rest_api.id
  lifecycle { create_before_destroy = true }
}

resource "aws_api_gateway_stage" "default" {
  deployment_id = aws_api_gateway_deployment.deployment.id
  rest_api_id   = aws_api_gateway_rest_api.rest_api.id
  stage_name    = "default"
}

resource "aws_api_gateway_domain_name" "domain_name" {
  domain_name              = "${var.app_name}-${var.env}.${var.zone_name}"
  regional_certificate_arn = aws_acm_certificate_validation.certificate_validation.certificate_arn
  endpoint_configuration { types = ["REGIONAL"] }
}

resource "aws_route53_record" "alias_record" {
  name    = aws_api_gateway_domain_name.domain_name.domain_name
  type    = "A"
  zone_id = data.aws_route53_zone.public.zone_id
  alias {
    evaluate_target_health = false
    name                   = aws_api_gateway_domain_name.domain_name.regional_domain_name
    zone_id                = aws_api_gateway_domain_name.domain_name.regional_zone_id
  }
}

resource "aws_api_gateway_base_path_mapping" "mapping" {
  domain_name = aws_api_gateway_domain_name.domain_name.domain_name
  stage_name  = aws_api_gateway_stage.default.stage_name
  api_id      = aws_api_gateway_rest_api.rest_api.id
}
