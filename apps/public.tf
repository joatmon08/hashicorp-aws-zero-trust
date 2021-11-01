locals {
  public_log_config = {
    logDriver = "awslogs"
    options = {
      awslogs-group         = aws_cloudwatch_log_group.log_group.name
      awslogs-region        = local.region
      awslogs-stream-prefix = "public"
    }
  }
  public_api_name = "${var.name}-public-api"
}

resource "aws_ecs_service" "public_api" {
  name            = local.public_api_name
  cluster         = local.ecs_cluster_name
  task_definition = module.public_api.task_definition_arn
  desired_count   = 1
  network_configuration {
    subnets         = local.private_subnets
    security_groups = [local.ecs_security_group]
  }
  launch_type            = "EC2"
  propagate_tags         = "TASK_DEFINITION"
  enable_execute_command = true
}

module "public_api" {
  source                   = "hashicorp/consul-ecs/aws//modules/mesh-task"
  version                  = "0.2.0-beta2"
  tags                     = merge(local.tags, { Service = "public-api" })
  requires_compatibilities = ["EC2"]
  family                   = local.public_api_name
  port                     = "8080"
  log_configuration        = local.public_log_config
  container_definitions = [{
    name             = "public-api"
    image            = "hashicorpdemoapp/public-api:v0.0.5"
    essential        = true
    logConfiguration = local.public_log_config
    environment = [{
      name  = "NAME"
      value = local.public_api_name
      }, {
      name  = "BIND_ADDRESS"
      value = ":8080"
      }, {
      name  = "PRODUCT_API_URI"
      value = "http://localhost:9090"
    }]
    portMappings = [
      {
        containerPort = 8080
        hostPort      = 8080
        protocol      = "tcp"
      }
    ]
    cpu         = 0
    mountPoints = []
    volumesFrom = []
  }]
  upstreams = [
    {
      destination_name = local.product_api_name
      local_bind_port  = 9090
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
