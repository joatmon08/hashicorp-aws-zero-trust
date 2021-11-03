resource "boundary_credential_store_vault" "hcp" {
  name        = "hcp"
  description = "HCP Vault credentials store"
  address     = local.vault_address
  token       = local.vault_boundary_token
  scope_id    = boundary_scope.products_infra.id
  namespace   = local.vault_namespace
}

resource "boundary_credential_library_vault" "database" {
  name                = "database"
  description         = "HCP Vault credential library for database"
  credential_store_id = boundary_credential_store_vault.hcp.id
  path                = local.vault_boundary_database_path
  http_method         = "GET"
}
