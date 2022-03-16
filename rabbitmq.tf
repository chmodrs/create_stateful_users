resource "rabbitmq_vhost" "vhost" {
  # count = var.enableRabbitmq ? 1 : 0
  name = var.namespace
}

resource "rabbitmq_user" "user" {
  name     = var.namespace
  password = var.password
  tags     = ["administrator"]
}

resource "rabbitmq_permissions" "test" {
  # count = var.enableRabbitmq ? 1 : 0
  user  = rabbitmq_user.user.name
  vhost = rabbitmq_vhost.vhost.name

  permissions {
    configure = ".*"
    write     = ".*"
    read      = ".*"
  }
}