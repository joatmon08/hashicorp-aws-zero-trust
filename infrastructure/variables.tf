variable "region" {
  type        = string
  description = "AWS Region"
  default     = "us-east-1"
  validation {
    condition     = contains(["us-east-1", "us-west-2"], var.region)
    error_message = "Region must be a valid one for HCP."
  }
}

variable "name" {
  type        = string
  description = "Name for infrastructure resources"
}

variable "default_tags" {
  type        = map(string)
  description = "Default tags to add to infrastructure resources"
  default = {
    Service = "hashicups"
    Purpose = "aws-reinvent-2021"
  }
}

variable "vpc_cidr_block" {
  type        = string
  description = "AWS VPC CIDR Block. Must be different than HVN CIDR Block."
  default     = "10.0.0.0/16"
}

variable "ecs_cluster_size" {
  default     = 1
  type        = number
  description = "Number of ECS container instances to create"
}

variable "database_username" {
  default     = "postgres"
  type        = string
  description = "Username for postgresql"
}

variable "database_password" {
  type        = string
  description = "Password for postgresql"
  sensitive   = true
}

variable "boundary_database_password" {
  type        = string
  description = "Password for Boundary database"
  sensitive   = true
}

variable "key_pair_name" {
  type        = string
  description = "AWS key pair to log into EC2 instances"
}

variable "client_cidr_block" {
  type        = string
  description = "Client CIDR blocks to allow access to EC2 instances"
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

locals {
  region         = data.terraform_remote_state.hcp.outputs.region
  hvn_id         = data.terraform_remote_state.hcp.outputs.hcp_network_id
  hvn_self_link  = data.terraform_remote_state.hcp.outputs.hcp_network_self_link
  hvn_cidr_block = data.terraform_remote_state.hcp.outputs.hcp_network_cidr_block
  hcp_consul_id  = data.terraform_remote_state.hcp.outputs.hcp_consul_id
  hcp_vault_id   = data.terraform_remote_state.hcp.outputs.hcp_vault_id
}
