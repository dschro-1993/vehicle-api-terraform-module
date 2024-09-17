variable "root_path" {
  type = string
}

variable "code_path" {
  type = string
}

variable "zone_name" {
  type = string
}

variable "web_acl_logging_enabled" {
  default = false
  type    = bool
}

variable "api_gateway_execution_logging_enabled" {
  default = false
  type    = bool
}

variable "api_gateway_access_logging_enabled" {
  default = false
  type    = bool
}

variable "lambda_layer_output_file" {
  type = string
}

variable "lambda_layer_output_path" {
  type = string
}

variable "lambda_handler" {
  type = string
}

variable "app_version" {
  type = string
}

variable "app_name" {
  type = string
}

variable "env_vars" {
  type = map(any)
}

variable "env" {
  type = string
}
