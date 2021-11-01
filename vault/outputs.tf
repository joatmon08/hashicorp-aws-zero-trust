output "vault_token_boundary" {
  value = vault_token.boundary.client_token
  sensitive = true
}