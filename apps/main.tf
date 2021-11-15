terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.65"
    }
    consul = {
      source  = "hashicorp/consul"
      version = "~> 2.14"
    }
  }
}

provider "aws" {
  region = local.region
  default_tags {
    tags = var.default_tags
  }
}

provider "consul" {
  address    = local.consul_addr
  datacenter = local.consul_datacenter
  token      = local.consul_token
}
