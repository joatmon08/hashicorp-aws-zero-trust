data "terraform_remote_state" "hcp" {
  backend = "remote"

  config = {
    organization = "hashicorp-aws-zero-trust"
    workspaces = {
      name = "hcp"
    }
  }
}

data "hcp_consul_cluster" "cluster" {
  cluster_id = local.consul_cluster_id
}

resource "hcp_consul_cluster_root_token" "cluster" {
  cluster_id = local.consul_cluster_id
}

locals {
  consul_cluster_id = data.terraform_remote_state.hcp.outputs.hcp_consul_id
  consul_addr       = data.terraform_remote_state.hcp.outputs.hcp_consul_public_endpoint
  consul_datacenter = data.hcp_consul_cluster.cluster.datacenter
  consul_token      = hcp_consul_cluster_root_token.cluster.secret_id
}


variable "name" {
  type        = string
  description = "Name for ECS task and service"
}