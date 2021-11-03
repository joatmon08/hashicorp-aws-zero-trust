export VAULT_ADDR=$(cd hcp && terraform output -raw hcp_vault_public_endpoint)
export VAULT_TOKEN=$(cd hcp && terraform output -raw hcp_vault_admin_token)
export VAULT_NAMESPACE=$(cd hcp && terraform output -raw hcp_vault_namespace)

export CONSUL_HTTP_ADDR=$(cd hcp && terraform output -raw hcp_consul_public_endpoint)
export CONSUL_HTTP_TOKEN=$(cd hcp && terraform output -raw hcp_consul_root_token)

export BOUNDARY_ADDR=$(cd infrastructure && terraform output -raw boundary_endpoint)