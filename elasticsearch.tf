resource "elasticstack_elasticsearch_security_role" "role" {
  # count   = var.enableElasticsearch ? 1 : 0
  name    = "${var.namespace}-role"
  cluster = ["monitor"]

  indices {
    names      = ["${var.namespace}-integ-*"]
    privileges = ["all", "create_index", "write", "manage_follow_index"]
  }

  applications {
    application = "kibana-.kibana"
    privileges  = ["read"]
    resources   = ["*"]
  }

}

# output "role" {
#   value = elasticstack_elasticsearch_security_role.role
# }


resource "elasticstack_elasticsearch_security_user" "user" {
  # count     = var.enableElasticsearch ? 1 : 0
  username  = var.namespace
  full_name = "${var.namespace}-user"
  password  = var.password
  roles     = ["${elasticstack_elasticsearch_security_role.role.name}"]
  enabled   = true

}