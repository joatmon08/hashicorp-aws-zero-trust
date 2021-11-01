resource "vault_mount" "postgres" {
  path = "${var.name}/database"
  type = "database"
}

# resource "vault_database_secret_backend_connection" "postgres" {
#   backend       = vault_mount.postgres.path
#   name          = "product"
#   allowed_roles = ["*"]

#   postgresql {
#     connection_url = "postgresql://${local.postgres_username}:${local.postgres_password}@${local.postgres_hostname}:${local.postgres_port}/products?sslmode=disable"
#   }
# }

# resource "vault_database_secret_backend_static_role" "postgres" {
#   backend             = vault_mount.postgres.path
#   name                = "product"
#   db_name             = vault_database_secret_backend_connection.postgres.name
#   username            = "product-api"
#   rotation_period     = "604800"
#   rotation_statements = ["ALTER USER \"{{name}}\" WITH PASSWORD '{{password}}';"]
# }

# data "vault_policy_document" "product" {
#   rule {
#     path         = "${vault_mount.postgres.path}/creds/product"
#     capabilities = ["read"]
#     description  = "read all credentials for product database"
#   }
# }

# resource "vault_policy" "product" {
#   name   = "product"
#   policy = data.vault_policy_document.product.hcl
# }