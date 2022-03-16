resource "mongodb_db_user" "user" {
  # count         = var.enableMongodb ? 1 : 0
  auth_database = var.namespace
  name          = var.namespace
  password      = var.password
  role {
    role = "readWrite"
    db   = var.namespace
  }
}