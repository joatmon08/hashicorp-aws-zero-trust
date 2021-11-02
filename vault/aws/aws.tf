resource "vault_aws_secret_backend" "aws" {
  path       = "terraform/aws"
  access_key = var.aws_access_key_id
  secret_key = var.aws_secret_access_key
}

resource "vault_aws_secret_backend_role" "role" {
  backend         = vault_aws_secret_backend.aws.path
  name            = var.name
  credential_type = "assumed_role"
  role_arns       = local.aws_role_arns
  default_sts_ttl = local.aws_sts_duration
  max_sts_ttl     = 43200
}

data "vault_policy_document" "aws" {
  rule {
    path         = "${vault_aws_secret_backend.aws.path}/creds/${var.name}"
    capabilities = ["read"]
    description  = "read AWS credentials for Terraform to use"
  }
}

resource "vault_policy" "aws" {
  name   = "terraform"
  policy = data.vault_policy_document.aws.hcl
}
