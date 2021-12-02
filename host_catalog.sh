#!/bin/bash

mkdir -p secrets/

echo "vault read boundary/aws/creds/ecs -format=json > secrets/boundary_host.json"
vault read boundary/aws/creds/ecs -format=json > secrets/boundary_host.json
read -n1

echo "cat secrets/boundary_host.json | jq .data.access_key"
cat secrets/boundary_host.json | jq .data.access_key
read -n1

AWS_ACCESS_KEY_ID=$(cat secrets/boundary_host.json | jq -r .data.access_key)
AWS_SECRET_ACCESS_KEY=$(cat secrets/boundary_host.json | jq -r .data.secret_key)
ECS_CLUSTER=$(cd infrastructure && terraform output -raw ecs_cluster)

echo 'boundary host-catalogs create plugin -format=json -plugin-name="aws" -scope-id='$(cd boundary && terraform output -raw core_infra_scope_id)' -attr="disable_credential_rotation=true" -attr="region='$(cd hcp && terraform output -raw region)'" -secret="access_key_id=${AWS_ACCESS_KEY_ID}" -secret="secret_access_key=${AWS_SECRET_ACCESS_KEY}" > secrets/host_catalog_config.json'
boundary host-catalogs create plugin -format=json \
  -plugin-name="aws" \
  -scope-id=$(cd boundary && terraform output -raw core_infra_scope_id) \
  -attr="disable_credential_rotation=true" \
  -attr="region=$(cd hcp && terraform output -raw region)" \
  -secret="access_key_id=${AWS_ACCESS_KEY_ID}" \
  -secret="secret_access_key=${AWS_SECRET_ACCESS_KEY}" > secrets/host_catalog_config.json
read -n1

echo "boundary host-sets create plugin -format=json -name='ecs-nodes' -host-catalog-id=$(cat secrets/host_catalog_config.json | jq -r '.item.id') --attributes='{\"filters\": [\"tag:Cluster=${ECS_CLUSTER}\"]}' > secrets/host_set_config.json"
boundary host-sets create plugin -format=json \
  -name="ecs-nodes" \
  -host-catalog-id=$(cat secrets/host_catalog_config.json | jq -r '.item.id') \
  --attributes='{"filters": ["tag:Cluster='${ECS_CLUSTER}'"]}' > secrets/host_set_config.json
read -n1

echo "boundary targets add-host-sets -host-set=$(cat secrets/host_set_config.json | jq -r '.item.id') -id=$(cd boundary && terraform output -raw boundary_target_ecs)"
boundary targets add-host-sets \
  -host-set=$(cat secrets/host_set_config.json | jq -r '.item.id') \
  -id=$(cd boundary && terraform output -raw boundary_target_ecs)
read -n1

echo "boundary hosts list -host-catalog-id=$(cat secrets/host_catalog_config.json | jq -r '.item.id')"
boundary hosts list -host-catalog-id=$(cat secrets/host_catalog_config.json | jq -r '.item.id')