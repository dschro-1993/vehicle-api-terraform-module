data "aws_region" "current" {}

data "aws_route53_zone" "public" {
  name = var.zone_name
}
