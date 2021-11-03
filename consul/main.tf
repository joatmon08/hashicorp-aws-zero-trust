terraform {
  required_providers {
    consul = {
      source  = "hashicorp/consul"
      version = "~> 2.14"
    }
  }
}

provider "consul" {
  address    = local.consul_addr
  datacenter = local.consul_datacenter
  token      = local.consul_token
}