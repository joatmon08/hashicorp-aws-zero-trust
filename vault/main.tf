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

provider "hcp" {}

provider "vault" {
  address   = local.vault_addr
  namespace = local.vault_namespace
  token     = local.vault_token
}