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
  type        = string
  description = "Client CIDR blocks to allow access to EC2 instances"
}

variable "db_username" {
  type        = string
  description = "Database username for products information"
}

variable "db_password" {
  type        = string
  description = "Database password for products information"
  sensitive   = true
}

locals {

  tags = {
    Name    = var.name,
    Purpose = var.purpose,
  }
  ecs_cluster_name   = data.terraform_remote_state.infrastructure.outputs.ecs_cluster
  ecs_security_group = data.terraform_remote_state.infrastructure.outputs.ecs_security_group
  region             = data.terraform_remote_state.infrastructure.outputs.region
  consul_attributes  = data.terraform_remote_state.infrastructure.outputs.consul_attributes
  vpc_id             = data.terraform_remote_state.infrastructure.outputs.vpc_id
  private_subnets    = data.terraform_remote_state.infrastructure.outputs.private_subnets
  public_subnets     = data.terraform_remote_state.infrastructure.outputs.public_subnets
  db_address         = data.terraform_remote_state.infrastructure.outputs.product_database_address
  db_username        = var.db_username
  db_password        = var.db_password
}