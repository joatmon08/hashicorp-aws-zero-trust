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

data "terraform_remote_state" "vault" {
  backend = "remote"

  config = {
    organization = "hashicorp-aws-zero-trust"
    workspaces = {
      name = "vault-products"
    }
  }
}

variable "name" {
  type = string
}

variable "operations_team" {
  type = set(string)
}

variable "products_team" {
  type = set(string)
}

variable "security_team" {
  type = set(string)
}

data "aws_instances" "ecs" {
  instance_tags = {
    "Cluster" = local.ecs_cluster_name
  }
}

locals {
  ecs_cluster_name                 = data.terraform_remote_state.infrastructure.outputs.ecs_cluster
  region                           = data.terraform_remote_state.infrastructure.outputs.region
  url                              = data.terraform_remote_state.infrastructure.outputs.boundary_endpoint
  kms_recovery_key_id              = data.terraform_remote_state.infrastructure.outputs.boundary_kms_recovery_key_id
  ecs_container_instances          = toset(data.aws_instances.ecs.private_ips)
  products_database_target_address = data.terraform_remote_state.infrastructure.outputs.product_database_address
  vault_address                    = data.terraform_remote_state.hcp.outputs.hcp_vault_private_endpoint
  vault_namespace                  = data.terraform_remote_state.hcp.outputs.hcp_vault_namespace
  vault_boundary_token             = data.terraform_remote_state.vault.outputs.boundary_token
  vault_boundary_database_path     = data.terraform_remote_state.vault.outputs.boundary_database_credentials_path
}
