variable "root_path" {
  type = string
}

variable "code_path" {
  type = string
}

variable "zone_name" {
  type = string
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

variable "hash_key_name" {
  default = "Id"
  type    = string
}

variable "hash_key_type" {
  default = "S"
  type    = string
}

variable "env_vars" {
  type = map(any)
}

variable "env" {
  type = string
}
