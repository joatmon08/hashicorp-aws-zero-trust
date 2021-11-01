locals {
  product_log_config = {
    logDriver = "awslogs"
    options = {
      awslogs-group         = aws_cloudwatch_log_group.log_group.name
      awslogs-region        = local.region
      awslogs-stream-prefix = "product"
    }
  }
  product_api_name = "${var.name}-product-api"
}

resource "aws_secretsmanager_secret" "database" {
  name                    = "${var.name}-products-database"
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "database" {
  secret_id     = aws_secretsmanager_secret.database.id
  secret_string = "host=${local.db_address} port=5432 user=${local.db_username} password=${local.db_password} dbname=products sslmode=disable"
}

resource "aws_iam_policy" "database" {
  name        = "${var.name}-product-database"
  path        = "/ecs/"
  description = "${var.name}-product-database configuration for product-api"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "secretsmanager:GetSecretValue"
      ],
      "Resource": [
        "${aws_secretsmanager_secret.database.arn}"
      ]
    }
  ]
}
EOF
}

resource "aws_ecs_service" "product_api" {
  name            = local.product_api_name
  cluster         = local.ecs_cluster_name
  task_definition = module.product_api.task_definition_arn
  desired_count   = 1
  network_configuration {
    subnets         = local.private_subnets
    security_groups = [local.ecs_security_group]
  }
  launch_type            = "EC2"
  propagate_tags         = "TASK_DEFINITION"
  enable_execute_command = true
}

module "product_api" {
  source                             = "hashicorp/consul-ecs/aws//modules/mesh-task"
  version                            = "0.2.0-beta2"
  tags                               = merge(local.tags, { Service = "product-api" })
  requires_compatibilities           = ["EC2"]
  family                             = local.product_api_name
  port                               = "9090"
  log_configuration                  = local.product_log_config
  additional_execution_role_policies = [aws_iam_policy.database.arn]
  container_definitions = [{
    name             = "product-api"
    image            = "joatmon08/product-api:v0.0.18"
    essential        = true
    logConfiguration = local.product_log_config
    environment = [{
      name  = "NAME"
      value = local.product_api_name
    }]
    secrets = [{
      name      = "DB_CONNECTION"
      valueFrom = aws_secretsmanager_secret.database.arn
    }]
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
  retry_join                     = local.consul_attributes.consul_retry_join
  tls                            = true
  consul_server_ca_cert_arn      = local.consul_attributes.consul_server_ca_cert_arn
  gossip_key_secret_arn          = local.consul_attributes.gossip_key_secret_arn
  acls                           = true
  consul_client_token_secret_arn = local.consul_attributes.consul_client_token_secret_arn
  acl_secret_name_prefix         = local.consul_attributes.acl_secret_name_prefix
}
