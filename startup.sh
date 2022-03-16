#!/bin/sh

rm -rf .terraform
terraform --version
terraform init -backend-config="access_key=$INTERNO_DEV_MINIO_ACCESS_KEY" -backend-config="secret_key=$INTERNO_DEV_MINIO_SECRET_KEY" -backend-config="key=$TF_VAR_namespace-create_stateful_users" -backend-config="bucket=terraform-tf-state"