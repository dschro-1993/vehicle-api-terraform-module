data "aws_route53_zone" "public" {
  name = var.zone_name
}
