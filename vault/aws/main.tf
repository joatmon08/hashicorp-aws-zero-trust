terraform {
  required_providers {
    consul = {
      source  = "hashicorp/vault"
      version = "~> 2.24"
    }
  }
}

provider "vault" {
  address   = data.terraform_remote_state.hcp.outputs.hcp_vault_public_endpoint
  token     = data.terraform_remote_state.hcp.outputs.hcp_vault_admin_token
  namespace = data.terraform_remote_state.hcp.outputs.hcp_vault_namespace
}
