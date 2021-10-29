output "region" {
  value = local.region
}
output "boundary_endpoint" {
  value = "http://${module.boundary.boundary_lb}:9200"
}

output "boundary_kms_recovery_key_id" {
  value = module.boundary.kms_recovery_key_id
}

output "product_database_address" {
  value = aws_db_instance.products.address
}

output "product_database_username" {
  value = aws_db_instance.products.username
}

output "product_database_password" {
  value     = aws_db_instance.products.password
  sensitive = true
}

output "ecs_cluster" {
  value = aws_ecs_cluster.cluster.name
}

output "consul_attributes" {
  sensitive = true

  value = {
    acl_secret_name_prefix         = var.name
    consul_server_ca_cert_arn      = aws_secretsmanager_secret.consul_ca_cert.arn
    gossip_key_secret_arn          = aws_secretsmanager_secret.gossip_key.arn
    consul_client_token_secret_arn = module.consul_acl_controller.client_token_secret_arn
    consul_retry_join              = jsondecode(base64decode(data.hcp_consul_cluster.cluster.consul_config_file))["retry_join"][0]
  }
}