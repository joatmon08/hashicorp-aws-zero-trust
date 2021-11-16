data "terraform_remote_state" "infrastructure" {
  backend = "remote"

  config = {
    organization = "hashicorp-aws-zero-trust"
    workspaces = {
      name = "infrastructure"
    }
  }
}

data "terraform_remote_state" "hcp" {
  backend = "remote"

  config = {
    organization = "hashicorp-aws-zero-trust"
    workspaces = {
      name = "hcp"
    }
  }
}

data "terraform_remote_state" "vault_products" {
  backend = "remote"

  config = {
    organization = "hashicorp-aws-zero-trust"
    workspaces = {
      name = "vault-products"
    }
  }
}

variable "name" {
  type        = string
  description = "Name for ECS task and service"
}

variable "client_cidr_block" {
  type        = string
  description = "Client CIDR blocks to allow access to EC2 instances"
}

variable "default_tags" {
  type        = map(string)
  description = "Default tags to add to infrastructure resources"
  default = {
    Service = "hashicups"
    Purpose = "aws-reinvent-2021"
  }
}

locals {
  consul_cluster_id           = data.terraform_remote_state.hcp.outputs.hcp_consul_id
  consul_addr                 = data.terraform_remote_state.hcp.outputs.hcp_consul_public_endpoint
  consul_datacenter           = data.terraform_remote_state.hcp.outputs.hcp_consul_datacenter
  consul_token                = data.terraform_remote_state.hcp.outputs.hcp_consul_root_token
  ecs_cluster_name            = data.terraform_remote_state.infrastructure.outputs.ecs_cluster
  ecs_security_group          = data.terraform_remote_state.infrastructure.outputs.ecs_security_group
  region                      = data.terraform_remote_state.infrastructure.outputs.region
  consul_attributes           = data.terraform_remote_state.infrastructure.outputs.consul_attributes
  vpc_id                      = data.terraform_remote_state.infrastructure.outputs.vpc_id
  private_subnets             = data.terraform_remote_state.infrastructure.outputs.private_subnets
  public_subnets              = data.terraform_remote_state.infrastructure.outputs.public_subnets
  db_address                  = data.terraform_remote_state.infrastructure.outputs.product_database_address
  hcp_vault_private_endnpoint = data.terraform_remote_state.hcp.outputs.hcp_vault_private_endpoint
  hcp_vault_namespace         = data.terraform_remote_state.hcp.outputs.hcp_vault_namespace
  vault_database_creds_path   = data.terraform_remote_state.vault_products.outputs.products_database_credentials_path
}
