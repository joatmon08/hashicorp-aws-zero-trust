terraform {
  required_providers {
    consul = {
      source  = "hashicorp/vault"
      version = "~> 2.24"
    }
    hcp = {
      source  = "hashicorp/hcp"
      version = "~> 0.18"
    }
  }
}


data "hcp_vault_cluster" "cluster" {
  cluster_id = data.terraform_remote_state.hcp.outputs.hcp_vault_id
}



provider "hcp" {}

provider "vault" {}