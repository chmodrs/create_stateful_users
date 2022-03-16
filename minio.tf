# Create a bucket.

resource "minio_bucket" "bucket" {
  # count = var.enableMinio ? 1 : 0
  name = var.namespace
}

resource "minio_user" "user" {
  access_key = var.namespace
  secret_key = var.password
  policies = [
    minio_canned_policy.policy.name
    # Note: using a data source here!
    #data.minio_canned_policy.console_admin.name,
  ]
  /*groups = [
    minio_group.group2.name,
  ]*/
  depends_on = [
    minio_canned_policy.policy,
  ]
}

# Create a policy.
resource "minio_canned_policy" "policy" {
  # count = var.enableMinio ? 1 : 0
  name = "policy"
  policy = jsonencode(
    {
      Statement = [
        {
          Action = [
            "s3:GetBucketLocation",
          ]
          Effect = "Allow"
          Resource = [
            "arn:aws:s3:::${minio_bucket.bucket.name}*",
          ]
        },
        {
          Action = [
            "s3:ListAllMyBuckets",
          ]
          Effect = "Allow"
          Resource = [
            "arn:aws:s3:::${minio_bucket.bucket.name}*",
          ]
        },
        {
          Action = [
            "s3:ListBucket",
          ]
          Effect = "Allow"
          Resource = [
            "arn:aws:s3:::${minio_bucket.bucket.name}",
          ]
        },
        {
          Action = [
            "s3:GetObject",
          ]
          Effect = "Allow"
          Resource = [
            "arn:aws:s3:::${minio_bucket.bucket.name}/*",
          ]
        },
        {
          Action = [
            "s3:PutObject",
          ]
          Effect = "Allow"
          Resource = [
            "arn:aws:s3:::${minio_bucket.bucket.name}/*",
          ]
        },
        {
          Action = [
            "s3:DeleteObject",
          ]
          Effect = "Allow"
          Resource = [
            "arn:aws:s3:::${minio_bucket.bucket.name}/*",
          ]
        },
      ]
      Version = "2012-10-17"
    }
  )
}

/*# Create a user group and assign the specified policies.
resource "minio_group" "group1" {
  name = "group1"
  policies = [minio_canned_policy.policy1.name]
}

resource "minio_group" "group2" {
  name = "group2"
}*/


# Import an existing policy.
# (the consoleAdmin policy is created by Minio automatically)
/*data "minio_canned_policy" "console_admin" {
  name = "consoleAdmin"
}*/

# Create a user with specified access credentials, policies and group membership.
