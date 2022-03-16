data "terraform_remote_state" "create_namespace_user" {
  backend = "s3"
  config = {
    bucket                      = "terraform-tf-state"
    region                      = "main"
    key                         = "${var.namespace}-create_namespace_user"
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    skip_region_validation      = true
    force_path_style            = true
    endpoint                    = "${var.minio_endpoint}"
    access_key                  = "${var.access_key}"
    secret_key                  = "${var.secret_key}"
  }
}