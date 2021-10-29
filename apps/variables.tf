data "terraform_remote_state" "infrastructure" {
  backend = "remote"

  config = {
    organization = "hashicorp-aws-zero-trust"
    workspaces = {
      name = "infrastructure"
    }
  }
}

variable "name" {
  type        = string
  description = "Name for ECS task and service"
}

variable "purpose" {
  type        = string
  description = "Purpose for ECS task and service"
}

variable "client_cidr_block" {
  type        = list(string)
  description = "Client CIDR blocks to allow access to EC2 instances"
}


locals {
  ecs_cluster_name   = data.terraform_remote_state.infrastructure.outputs.ecs_cluster
  ecs_security_group = data.terraform_remote_state.infrastructure.outputs.ecs_security_group
  region             = data.terraform_remote_state.infrastructure.outputs.region
  consul_attributes  = data.terraform_remote_state.infrastructure.outputs.consul_attributes
  vpc_id             = data.terraform_remote_state.infrastructure.outputs.vpc_id
  private_subnets    = data.terraform_remote_state.infrastructure.outputs.private_subnets
  public_subnets     = data.terraform_remote_state.infrastructure.outputs.public_subnets
}