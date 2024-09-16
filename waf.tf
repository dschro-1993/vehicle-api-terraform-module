locals {
  rules = ["AWSManagedRulesCommonRuleSet"]
}

resource "aws_wafv2_web_acl_association" "web_acl_association" {
  resource_arn = aws_api_gateway_stage.default.arn
  web_acl_arn  = aws_wafv2_web_acl.web_acl.arn
}

resource "aws_wafv2_web_acl" "web_acl" {
  scope = "REGIONAL"
  name  = "${var.app_name}-${var.env}-web-acl"

  # Todo: Add Firehose/S3 for logging

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "${var.app_name}-${var.env}-web-acl"
    sampled_requests_enabled   = true
  }

  default_action {
    allow {}
  }

  rule {
    name     = "QuotaRule"
    priority = length(local.rules) + 1
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "${var.app_name}-${var.env}-quota-rule"
      sampled_requests_enabled   = true
    }
    statement {
      rate_based_statement {
        limit              = 100
        aggregate_key_type = "IP"
      }
    }
    action {
      block {}
    }
  }

  dynamic "rule" {
    for_each = toset(local.rules)
    content {
      name     = rule.value
      priority = index(local.rules, rule.value) + 1

      visibility_config {
        cloudwatch_metrics_enabled = true
        metric_name                = "${var.app_name}-${var.env}-${rule.value}"
        sampled_requests_enabled   = true
      }
      statement {
        managed_rule_group_statement {
          name        = rule.value
          vendor_name = "AWS"
        }
      }
      override_action {
        none {}
      }
    }
  }
}
