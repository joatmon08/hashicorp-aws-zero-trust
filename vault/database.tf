resource "vault_mount" "postgres" {
  path = "${var.name}/database"
  type = "database"
}

resource "vault_database_secret_backend_connection" "postgres" {
  backend       = vault_mount.postgres.path
  name          = "product"
  allowed_roles = ["*"]

  postgresql {
    connection_url = "postgresql://${local.postgres_username}:${local.postgres_password}@${local.postgres_hostname}:${local.postgres_port}/products?sslmode=disable"
  }
}

locals {
  products_creds_path = "${vault_mount.postgres.path}/creds/product"
  boundary_creds_path = "${vault_mount.postgres.path}/creds/boundary"
}

resource "vault_database_secret_backend_role" "product" {
  backend               = vault_mount.postgres.path
  name                  = "product"
  db_name               = vault_database_secret_backend_connection.postgres.name
  creation_statements   = ["CREATE ROLE \"{{username}}\" WITH LOGIN PASSWORD '{{password}}' VALID UNTIL '{{expiration}}'; GRANT SELECT ON ALL TABLES IN SCHEMA public TO \"{{username}}\";"]
  revocation_statements = ["ALTER ROLE \"{{username}}\" NOLOGIN;"]
  default_ttl           = 604800
  max_ttl               = 604800
}

data "vault_policy_document" "product" {
  rule {
    path         = local.products_creds_path
    capabilities = ["read"]
    description  = "read all credentials for product database as product-api"
  }
}

resource "vault_policy" "product" {
  name   = "product"
  policy = data.vault_policy_document.product.hcl
}

resource "vault_database_secret_backend_role" "boundary" {
  backend               = vault_mount.postgres.path
  name                  = "boundary"
  db_name               = vault_database_secret_backend_connection.postgres.name
  creation_statements   = ["CREATE ROLE \"{{username}}\" WITH LOGIN PASSWORD '{{password}}' VALID UNTIL '{{expiration}}'; GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO \"{{username}}\"; GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO \"{{username}}\";"]
  revocation_statements = ["ALTER ROLE \"{{username}}\" NOLOGIN;"]
  default_ttl           = 3600
  max_ttl               = 3600
}

data "vault_policy_document" "boundary" {
  rule {
    path         = local.boundary_creds_path
    capabilities = ["read"]
    description  = "read all credentials for product database as boundary"
  }
}

resource "vault_policy" "boundary" {
  name   = "boundary"
  policy = data.vault_policy_document.boundary.hcl
}

resource "vault_token" "boundary" {
  role_name = vault_token_auth_backend_role.boundary.role_name
  policies  = [vault_policy.boundary.name]
  ttl       = "24h"
}

resource "vault_token_auth_backend_role" "boundary" {
  role_name           = "boundary"
  allowed_policies    = [vault_policy.boundary.name]
  disallowed_policies = ["default"]
  orphan              = true
  renewable           = true
}
