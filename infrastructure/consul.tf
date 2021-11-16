data "hcp_consul_cluster" "cluster" {
  cluster_id = local.hcp_consul_id
}

resource "hcp_consul_cluster_root_token" "cluster" {
  cluster_id = local.hcp_consul_id
}

resource "aws_secretsmanager_secret" "bootstrap_token" {
  name                    = "${var.name}-bootstrap-token"
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "bootstrap_token" {
  secret_id     = aws_secretsmanager_secret.bootstrap_token.id
  secret_string = hcp_consul_cluster_root_token.cluster.secret_id
}

resource "aws_secretsmanager_secret" "gossip_key" {
  name                    = "${var.name}-gossip-key"
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "gossip_key" {
  secret_id     = aws_secretsmanager_secret.gossip_key.id
  secret_string = jsondecode(base64decode(data.hcp_consul_cluster.cluster.consul_config_file))["encrypt"]
}

resource "aws_secretsmanager_secret" "consul_ca_cert" {
  name                    = "${var.name}-consul-ca-cert"
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "consul_ca_cert" {
  secret_id     = aws_secretsmanager_secret.consul_ca_cert.id
  secret_string = base64decode(data.hcp_consul_cluster.cluster.consul_ca_file)
}

resource "random_pet" "controller" {}

locals {
  acl_controller_prefix = "${var.name}-${random_pet.controller.id}"
}

module "consul_acl_controller" {
  source  = "hashicorp/consul-ecs/aws//modules/acl-controller"
  version = "0.2.0"
  log_configuration = {
    logDriver = "awslogs"
    options = {
      awslogs-group         = aws_cloudwatch_log_group.ecs.name
      awslogs-region        = local.region
      awslogs-stream-prefix = "consul-acl-controller"
    }
  }
  consul_bootstrap_token_secret_arn = aws_secretsmanager_secret.bootstrap_token.arn
  consul_server_http_addr           = data.hcp_consul_cluster.cluster.consul_private_endpoint_url
  ecs_cluster_arn                   = aws_ecs_cluster.cluster.arn
  region                            = local.region
  subnets                           = module.vpc.private_subnets
  name_prefix                       = local.acl_controller_prefix
}