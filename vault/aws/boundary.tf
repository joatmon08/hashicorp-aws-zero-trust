data "aws_caller_identity" "current" {}

resource "vault_aws_secret_backend" "boundary_host_catalog" {
  path                      = "boundary/aws"
  access_key                = var.aws_access_key_id
  secret_key                = var.aws_secret_access_key
  default_lease_ttl_seconds = local.aws_sts_duration
  max_lease_ttl_seconds     = 43200
}

resource "vault_aws_secret_backend_role" "boundary_host_catalog" {
  backend         = vault_aws_secret_backend.boundary_host_catalog.path
  name            = "ecs"
  credential_type = "iam_user"

  policy_document = <<EOT
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "ec2:DescribeInstances",
      "Resource": "*"
    },
    {
      "Action": [
        "iam:DeleteAccessKey",
        "iam:GetUser",
        "iam:CreateAccessKey"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/*"
    }
  ]
}
EOT
}

data "vault_policy_document" "boundary_host_catalog" {
  rule {
    path         = "${vault_aws_secret_backend.boundary_host_catalog.path}/creds/${vault_aws_secret_backend_role.boundary_host_catalog.name}"
    capabilities = ["read"]
    description  = "read AWS credentials for Boundary Host Catalog to use"
  }
}

resource "vault_policy" "boundary_host_catalog" {
  name   = "boundary-host-catalog"
  policy = data.vault_policy_document.aws.hcl
}
