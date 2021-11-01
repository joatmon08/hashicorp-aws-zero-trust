terraform {
  required_providers {
    consul = {
      source  = "hashicorp/consul"
      version = "~> 2.14"
    }
    hcp = {
      source  = "hashicorp/hcp"
      version = "~> 0.18"
    }
  }
}

provider "hcp" {}

provider "consul" {
  address    = local.consul_addr
  datacenter = local.consul_datacenter
  token      = local.consul_token
}