variable "name" {
  type        = string
  description = "Name for infrastructure resources"
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
