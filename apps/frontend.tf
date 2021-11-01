locals {
  frontend_log_config = {
    logDriver = "awslogs"
    options = {
      awslogs-group         = aws_cloudwatch_log_group.log_group.name
      awslogs-region        = local.region
      awslogs-stream-prefix = "frontend"
    }
  }
  frontend_name = "${var.name}-frontend"
}

resource "aws_ecs_service" "frontend" {
  name            = local.frontend_name
  cluster         = local.ecs_cluster_name
  task_definition = module.frontend.task_definition_arn
  desired_count   = 1
  network_configuration {
    subnets         = local.private_subnets
    security_groups = [local.ecs_security_group]
  }
  launch_type    = "EC2"
  propagate_tags = "TASK_DEFINITION"
  load_balancer {
    target_group_arn = aws_lb_target_group.frontend.arn
    container_name   = "frontend"
    container_port   = 80
  }
  enable_execute_command = true
}

module "frontend" {
  source                   = "hashicorp/consul-ecs/aws//modules/mesh-task"
  version                  = "0.2.0-beta2"
  tags                     = merge(local.tags, { Service = "frontend" })
  requires_compatibilities = ["EC2"]
  family                   = local.frontend_name
  port                     = "80"
  log_configuration        = local.frontend_log_config
  container_definitions = [{
    name             = "frontend"
    image            = "joatmon08/frontend:v0.0.6"
    essential        = true
    logConfiguration = local.frontend_log_config
    environment = [{
      name  = "NAME"
      value = local.frontend_name
    }]
    portMappings = [
      {
        containerPort = 80
        hostPort      = 80
        protocol      = "tcp"
      }
    ]
    cpu         = 0
    mountPoints = []
    volumesFrom = []
  }]
  upstreams = [
    {
      destination_name = local.public_api_name
      local_bind_port  = 8080
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
