# resource "boundary_host_catalog" "ecs_nodes" {
#   name        = "ecs_nodes"
#   description = "ECS container instances for operations team"
#   type        = "static"
#   scope_id    = boundary_scope.core_infra.id
# }

# resource "boundary_host" "ecs_nodes" {
#   for_each        = local.ecs_container_instances
#   type            = "static"
#   name            = "ecs_nodes_${each.value}"
#   description     = "ECS Node #${each.value}"
#   address         = each.key
#   host_catalog_id = boundary_host_catalog.ecs_nodes.id
# }

# resource "boundary_host_set" "ecs_nodes" {
#   type            = "static"
#   name            = "ecs_nodes"
#   description     = "Host set for EKS nodes"
#   host_catalog_id = boundary_host_catalog.ecs_nodes.id
#   host_ids        = [for host in boundary_host.ecs_nodes : host.id]
# }

resource "boundary_host_catalog" "products_database" {
  name        = "products_database"
  description = "Products database"
  type        = "static"
  scope_id    = boundary_scope.products_infra.id
}

resource "boundary_host" "products_database" {
  type            = "static"
  name            = "products_database"
  description     = "products database"
  address         = local.products_database_target_address
  host_catalog_id = boundary_host_catalog.products_database.id
}

resource "boundary_host_set" "products_database" {
  type            = "static"
  name            = "products_database"
  description     = "Host set for Product Database"
  host_catalog_id = boundary_host_catalog.products_database.id
  host_ids        = [boundary_host.products_database.id]
}