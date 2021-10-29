resource "aws_cloudwatch_log_group" "log_group" {
  name = "${var.name}-application"
}

locals {
  example_server_app_log_config = {
    logDriver = "awslogs"
    options = {
      awslogs-group         = aws_cloudwatch_log_group.log_group.name
      awslogs-region        = local.region
      awslogs-stream-prefix = "app"
    }
  }

  example_client_app_log_config = {
    logDriver = "awslogs"
    options = {
      awslogs-group         = aws_cloudwatch_log_group.log_group.name
      awslogs-region        = local.region
      awslogs-stream-prefix = "client"
    }
  }

  tags = {
    Name    = var.name,
    Purpose = var.purpose,
  }
}

module "example_client_app" {
  source                   = "hashicorp/consul-ecs/aws//modules/mesh-task"
  version                  = "0.2.0-beta2"
  tags                     = local.tags
  requires_compatibilities = ["FARGATE"]
  family                   = "${var.name}-example-client-app"
  port                     = "9090"
  log_configuration        = local.example_client_app_log_config
  container_definitions = [{
    name             = "example-client-app"
    image            = "ghcr.io/lkysow/fake-service:v0.21.0"
    essential        = true
    logConfiguration = local.example_client_app_log_config
    environment = [
      {
        name  = "NAME"
        value = "${var.name}-example-client-app"
      },
      {
        name  = "UPSTREAM_URIS"
        value = "http://localhost:1234"
      }
    ]
    portMappings = [
      {
        containerPort = 9090
        hostPort      = 9090
        protocol      = "tcp"
      }
    ]
    cpu         = 0
    mountPoints = []
    volumesFrom = []
  }]
  upstreams = [
    {
      destination_name = "${var.name}-example-server-app"
      local_bind_port  = 1234
    }
  ]
  retry_join                     = local.consul_attributes.consul_retry_join
  tls                            = true
  consul_server_ca_cert_arn      = local.consul_attributes.consul_server_ca_cert_arn
  gossip_key_secret_arn          = local.consul_attributes.gossip_key_secret_arn
  acls                           = true
  consul_client_token_secret_arn = local.consul_attributes.consul_client_token_secret_arn
  acl_secret_name_prefix         = local.consul_attributes.acl_secret_name_prefix
}

module "example_server_app" {
  source                   = "hashicorp/consul-ecs/aws//modules/mesh-task"
  version                  = "0.2.0-beta2"
  tags                     = local.tags
  requires_compatibilities = ["EC2"]
  family                   = "${var.name}-example-server-app"
  port                     = "9090"
  log_configuration        = local.example_server_app_log_config
  container_definitions = [{
    name             = "example-server-app"
    image            = "ghcr.io/lkysow/fake-service:v0.21.0"
    essential        = true
    logConfiguration = local.example_server_app_log_config
    environment = [
      {
        name  = "NAME"
        value = "${var.name}-example-server-app"
      }
    ]
  }]
  retry_join                     = local.consul_attributes.consul_retry_join
  tls                            = true
  consul_server_ca_cert_arn      = local.consul_attributes.consul_server_ca_cert_arn
  gossip_key_secret_arn          = local.consul_attributes.gossip_key_secret_arn
  acls                           = true
  consul_client_token_secret_arn = local.consul_attributes.consul_client_token_secret_arn
  acl_secret_name_prefix         = local.consul_attributes.acl_secret_name_prefix
}