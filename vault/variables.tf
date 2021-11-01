data "terraform_remote_state" "hcp" {
  backend = "remote"

  config = {
    organization = "hashicorp-aws-zero-trust"
    workspaces = {
      name = "hcp"
    }
  }
}

data "terraform_remote_state" "infrastructure" {
  backend = "remote"

  config = {
    organization = "hashicorp-aws-zero-trust"
    workspaces = {
      name = "infrastructure"
    }
  }
}

data "hcp_vault_cluster" "cluster" {
  cluster_id = local.vault_cluster_id
}

resource "hcp_vault_cluster_admin_token" "cluster" {
  cluster_id = local.vault_cluster_id
}

locals {
  vault_cluster_id  = data.terraform_remote_state.hcp.outputs.hcp_vault_id
  vault_addr        = data.terraform_remote_state.hcp.outputs.hcp_vault_public_endpoint
  vault_namespace   = data.hcp_vault_cluster.cluster.namespace
  vault_token       = hcp_vault_cluster_admin_token.cluster.token
  postgres_username = data.terraform_remote_state.infrastructure.outputs.data.terraform_remote_state.hcp.outputs.product_database_username
  postgres_password = data.terraform_remote_state.infrastructure.outputs.data.terraform_remote_state.hcp.outputs.product_database_password
  postgres_hostname = data.terraform_remote_state.infrastructure.outputs.data.terraform_remote_state.hcp.outputs.product_database_address
  postgres_port     = "5432"
}


variable "name" {
  type        = string
  description = "Name for ECS task and service"
}