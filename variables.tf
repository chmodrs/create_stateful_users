variable "helm_username" {
  type = string
}

variable "helm_password" {
  type = string
}

variable "wait" {
  type    = string
  default = "false"
}

variable "reuse_values" {
  type    = string
  default = "false"
}

variable "replace" {
  type    = string
  default = "false"
}

variable "debug" {
  type    = string
  default = "true"
}

variable "helm_repository" {
  type    = string
  default = ""
}

variable "registry_server" {
  type    = string
  default = ""
}

variable "registry_username" {
  type    = string
  default = ""
}

variable "registry_password" {
  type    = string
  default = ""
}

variable "host" {
  type    = string
  default = ""
}

variable "token" {
  type    = string
  default = ""
}

variable "cluster_ca_certificate" {
  type    = string
  default = ""
}

variable "access_key" {
  type    = string
  default = ""
}

variable "secret_key" {
  type      = string
  default   = ""
  sensitive = true
}

variable "minio_endpoint" {
  type    = string
  default = ""
}

variable "rabbitmq_endpoint" {
  type    = string
  default = ""
}

variable "rabbitmq_api_port" {
  type    = string
  default = ""
}

variable "rabbitmq_admin_user" {
  type    = string
  default = ""
}

variable "rabbitmq_admin_pass" {
  type    = string
  default = ""
}

variable "keycloak_admin_user" {
  type    = string
  default = ""
}

variable "keycloak_admin_pass" {
  type    = string
  default = ""
}

variable "namespace" {
  type    = string
  default = ""
}

variable "password" {
  type      = string
  default   = ""
  sensitive = true
}

variable "smtp_host" {
  type    = string
  default = ""
}

variable "smtp_mail" {
  type    = string
  default = ""
}

variable "smtp_port" {
  type    = string
  default = ""
}

variable "smtp_user" {
  type    = string
  default = ""
}

variable "smtp_password" {
  type      = string
  default   = ""
  sensitive = true
}

variable "keycloak_custom_federation_flavor" {
  type    = string
  default = ""
}

variable "keycloak_custom_federation_jdbcuri" {
  type    = string
  default = ""
}

variable "keycloak_custom_federation_user" {
  type    = string
  default = ""
}

variable "keycloak_custom_federation_password" {
  type      = string
  default   = ""
  sensitive = true
}

variable "elasticsearch_admin_user" {
  type    = string
  default = ""
}

variable "elasticsearch_admin_pass" {
  type      = string
  default   = ""
  sensitive = true
}

variable "mongodb_admin_user" {
  type    = string
  default = ""
}

variable "mongodb_admin_pass" {
  type      = string
  default   = ""
  sensitive = true
}
