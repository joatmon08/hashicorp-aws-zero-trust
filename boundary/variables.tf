data "terraform_remote_state" "infrastructure" {
  backend = "remote"

  config = {
    organization = "hashicorp-aws-zero-trust"
    workspaces = {
      name = "infrastructure"
    }
  }
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
}