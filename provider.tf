terraform {
  backend "s3" {
    #bucket                      = var.namespace
    #key                         = "terraform.tfstate"
    region                      = "main"
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    skip_region_validation      = true
    force_path_style            = true
  }
}

provider "helm" {
  kubernetes {
    host  = var.host
    token = data.terraform_remote_state.create_namespace_user.deploy_user_token
    #token                  = base64decode(var.token)
    cluster_ca_certificate = base64decode(var.cluster_ca_certificate)
  }
}

/*
provider "kubernetes" {
  config_path    = "./deploy-kubeconfig"
  config_context = "mp-release"
}*/


provider "kubernetes" {
  host  = var.host
  token = data.terraform_remote_state.create_namespace_user.deploy_user_token
  #token                  = base64decode(var.token)
  cluster_ca_certificate = base64decode(var.cluster_ca_certificate)
}


terraform {
  required_providers {
    rabbitmq = {
      source = "cyrilgdn/rabbitmq"
    }
    minio = {
      source = "refaktory/minio"
    }
    keycloak = {
      source = "mrparkers/keycloak"
    }
    elasticstack = {
      source = "elastic/elasticstack"
    }
    mongodb = {
      source = "Kaginari/mongodb"
    }
  }
}

# Configure the RabbitMQ provider
provider "rabbitmq" {
  endpoint = "${var.rabbitmq_endpoint}:${var.rabbitmq_api_port}"
  username = var.rabbitmq_admin_user
  password = var.rabbitmq_admin_pass
}

# Configure the MinIO provider
provider "minio" {
  # The Minio server endpoint.
  # NOTE: do NOT add an http:// or https:// prefix!
  # Set the `ssl = true/false` setting instead.
  endpoint = trimprefix("${var.minio_endpoint}", "https://")
  #endpoint = "minio.dev.cliente.com.br"
  # Specify your minio user access key here.
  access_key = var.access_key
  # Specify your minio user secret key here.
  secret_key = var.secret_key
  # If true, the server will be contacted via https://
  ssl = true
}

provider "keycloak" {
  client_id = "admin-cli"
  username  = var.keycloak_admin_user
  password  = var.keycloak_admin_pass
  url       = "https://identity.dev.cliente.com.br"
}

provider "elasticstack" {
  elasticsearch {
    username  = var.elasticsearch_admin_user
    password  = var.elasticsearch_admin_pass
    endpoints = ["https://elk.dev.cliente.com.br:9200"]
  }
}

# Configure the MongoDB Provider

provider "mongodb" {
  host          = "172.21.25.211"
  port          = "27017"
  username      = var.mongodb_admin_user
  password      = var.mongodb_admin_pass
  auth_database = "admin"
  ssl           = false
  retrywrites   = false
  direct        = true
}