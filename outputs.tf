output "aws_api_gateway_domain_name" {
  value = "https://${aws_api_gateway_domain_name.domain_name.domain_name}"
}
