terraform {
  required_providers {
    consul = {
      source  = "hashicorp/vault"
      version = "~> 2.24"
    }
  }
}

provider "vault" {}
