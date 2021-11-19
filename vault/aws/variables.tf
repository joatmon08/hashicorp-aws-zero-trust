variable "name" {
  type        = string
  description = "Name of the AWS secrets engine"
}

variable "default_tags" {
  type        = map(string)
  description = "Default tags to add to infrastructure resources"
  default = {
    Service = "hashicups"
    Purpose = "aws-reinvent-2021"
  }
}

variable "aws_access_key_id" {
  type        = string
  description = "AWS Access Key ID used to issue other keys"
}

variable "aws_secret_access_key" {
  type        = string
  sensitive   = true
  description = "AWS Secret Access Key used to issue other keys"
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
  region           = data.terraform_remote_state.hcp.outputs.region
  aws_role_arns    = data.terraform_remote_state.hcp.outputs.vault_aws_role_arns
  aws_sts_duration = data.terraform_remote_state.hcp.outputs.sts_duration
}
