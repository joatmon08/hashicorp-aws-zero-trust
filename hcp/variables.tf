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

variable "hcp_region" {
  type        = string
  description = "AWS Region"
  default     = "us-east-1"
  validation {
    condition     = contains(["us-east-1", "us-west-2"], var.hcp_region)
    error_message = "Region must be a valid one for HCP."
  }
}

variable "hcp_network_cidr_block" {
  type        = string
  description = "HCP CIDR Block for HashiCorp Virtual Network"
  default     = "172.25.16.0/20"
}

variable "trusted_role_arn" {
  type        = string
  description = "Role ARN for Vault's AWS Secrets Engine"
  sensitive   = true
}

variable "sts_duration" {
  type        = number
  description = "Default duration in seconds for session token"
  default     = 14400
}
