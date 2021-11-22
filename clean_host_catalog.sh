#!/bin/bash

boundary host-sets delete \
  -id=$(cat secrets/host_set_config.json | jq -r '.item.id')

boundary host-catalogs delete \
  -id=$(cat secrets/host_catalog_config.json | jq -r '.item.id')

rm secrets/host_set_config.json secrets/host_catalog_config.json secrets/boundary_host.json

vault lease revoke -f -prefix boundary/aws/creds/ecs