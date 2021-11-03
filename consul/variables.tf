data "terraform_remote_state" "hcp" {
  backend = "remote"

  config = {
    organization = "hashicorp-aws-zero-trust"
    workspaces = {
      name = "hcp"
    }
  }
}

locals {
  consul_cluster_id = data.terraform_remote_state.hcp.outputs.hcp_consul_id
  consul_addr       = data.terraform_remote_state.hcp.outputs.hcp_consul_public_endpoint
  consul_datacenter = data.terraform_remote_state.hcp.outputs.hcp_consul_datacenter
  consul_token      = data.terraform_remote_state.hcp.outputs.hcp_consul_root_token
}


variable "name" {
  type        = string
  description = "Name for ECS task and service"
}