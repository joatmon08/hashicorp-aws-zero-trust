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

locals {
  region            = data.terraform_remote_state.infrastructure.outputs.region
  postgres_username = data.terraform_remote_state.infrastructure.outputs.product_database_username
  postgres_password = data.terraform_remote_state.infrastructure.outputs.product_database_password
  postgres_hostname = data.terraform_remote_state.infrastructure.outputs.product_database_address
  postgres_port     = "5432"
}


variable "name" {
  type        = string
  description = "Name for ECS task and service"
}

variable "default_tags" {
  type        = map(string)
  description = "Default tags to add to infrastructure resources"
  default = {
    Service = "hashicups"
    Purpose = "aws-reinvent-2021"
  }
}