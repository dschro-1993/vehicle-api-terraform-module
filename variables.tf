# common

variable "app_name" {
  default = "vehicle-api"
  type    = string
}

variable "env" {
  type = string
}

# api-gateway

variable "openapi_spec_path" {
  type = string
}

variable "zone_name" {
  type = string
}

# lambda

variable "code_path" {
  type = string
}

variable "app_handler" {
  type = string
}

variable "app_version" {
  type = string
}

# dynamo

variable "hash_key_name" {
  default = "id"
  type    = string
}

variable "hash_key_type" {
  default = "S"
  type    = string
}

variable "pitr_enabled" {
  default = false
  type    = bool
}
