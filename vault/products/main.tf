terraform {
  required_providers {
    vault = {
      source  = "hashicorp/vault"
      version = "~> 2.24"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.65"
    }
  }
}

provider "aws" {
  region = local.region
  default_tags {
    tags = var.default_tags
  }
}

provider "vault" {
  address   = data.terraform_remote_state.hcp.outputs.hcp_vault_public_endpoint
  token     = data.terraform_remote_state.hcp.outputs.hcp_vault_admin_token
  namespace = data.terraform_remote_state.hcp.outputs.hcp_vault_namespace
}
