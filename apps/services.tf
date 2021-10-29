# # The client app is part of the service mesh. It calls
# # the server app through the service mesh.
# # It's exposed via a load balancer.
# resource "aws_ecs_service" "example_client_app" {
#   name            = "${var.name}-example-client-app"
#   cluster         = local.ecs_cluster_name
#   task_definition = module.example_client_app.task_definition_arn
#   desired_count   = 1
#   network_configuration {
#     subnets         = local.private_subnets
#     security_groups = [local.ecs_security_group]
#   }
#   launch_type    = "FARGATE"
#   propagate_tags = "TASK_DEFINITION"
#   load_balancer {
#     target_group_arn = aws_lb_target_group.example_client_app.arn
#     container_name   = "example-client-app"
#     container_port   = 9090
#   }
#   enable_execute_command = true
# }

# module "example_client_app" {
#   source                   = "hashicorp/consul-ecs/aws//modules/mesh-task"
#   version                  = "0.2.0-beta2"
#   tags                     = local.tags
#   requires_compatibilities = ["FARGATE"]
#   family                   = "${var.name}-example-client-app"
#   port                     = "9090"
#   log_configuration        = local.example_client_app_log_config
#   container_definitions = [{
#     name             = "example-client-app"
#     image            = "ghcr.io/lkysow/fake-service:v0.21.0"
#     essential        = true
#     logConfiguration = local.example_client_app_log_config
#     environment = [
#       {
#         name  = "NAME"
#         value = "${var.name}-example-client-app"
#       },
#       {
#         name  = "UPSTREAM_URIS"
#         value = "http://localhost:1234"
#       }
#     ]
#     portMappings = [
#       {
#         containerPort = 9090
#         hostPort      = 9090
#         protocol      = "tcp"
#       }
#     ]
#     cpu         = 0
#     mountPoints = []
#     volumesFrom = []
#   }]
#   upstreams = [
#     {
#       destination_name = "${var.name}-example-server-app"
#       local_bind_port  = 1234
#     }
#   ]
#   retry_join                     = local.consul_attributes.consul_retry_join
#   tls                            = true
#   consul_server_ca_cert_arn      = local.consul_attributes.consul_server_ca_cert_arn
#   gossip_key_secret_arn          = local.consul_attributes.gossip_key_secret_arn
#   acls                           = true
#   consul_client_token_secret_arn = local.consul_attributes.consul_client_token_secret_arn
#   acl_secret_name_prefix         = local.consul_attributes.acl_secret_name_prefix
# }