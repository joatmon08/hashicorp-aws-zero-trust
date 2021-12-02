AUTH_METHOD_ID:=$(shell cd boundary && terraform output -raw boundary_auth_method_id)

vault-aws:
	@mkdir -p secrets/
	vault read terraform/aws/creds/hashicups -format=json > secrets/aws.json
	@read -n1
	cat secrets/aws.json | jq .data.access_key
	@read -n1
	vault list sys/leases/lookup/terraform/aws/creds/hashicups

vault-boundary-host-catalog:
	@mkdir -p secrets/
	vault read boundary/aws/creds/ecs -format=json > secrets/boundary_host.json
	@read -n1
	cat secrets/boundary_host.json | jq .data.access_key

vault-db:
	@mkdir -p secrets/
	vault read hashicups/database/creds/product -format=json > secrets/products.json
	@read -n1
	cat secrets/products.json | jq .data.username
	@read -n1
	vault list sys/leases/lookup/hashicups/database/creds/product

vault-leases:
	vault list sys/leases/lookup/hashicups/database/creds/boundary

products:
	cd apps && terraform taint aws_ecs_service.product_api

boundary-auth-ops:
	@echo 'boundary authenticate password -login-name=jeff -password REDACTED -auth-method-id=$(AUTH_METHOD_ID)'
	@boundary authenticate password -login-name=jeff \
		-password $(shell cd boundary && terraform output -raw boundary_operations_password) \
		-auth-method-id=$(AUTH_METHOD_ID)

boundary-auth-dev:
	@echo 'boundary authenticate password -login-name=rosemary -password REDACTED -auth-method-id=$(AUTH_METHOD_ID)'
	@boundary authenticate password -login-name=rosemary \
		-password $(shell cd boundary && terraform output -raw boundary_products_password) \
		-auth-method-id=$(AUTH_METHOD_ID)

boundary-host-catalog: boundary-auth-ops
	bash host_catalog.sh

clean-boundary-host-catalog:
	bash clean_host_catalog.sh

ssh-ecs: boundary-auth-ops
	@read -n1
	boundary connect ssh -username=ec2-user \
		-target-id $(shell cd boundary && terraform output -raw boundary_target_ecs) -- -i ~/.ssh/aws/rosemary-us-east-1.pem

postgres-creds:
	boundary targets authorize-session \
		-id $(shell cd boundary && terraform output -raw boundary_target_postgres) \
		-format json > secrets/boundary_db.json
	@read -n1
	cat secrets/boundary_db.json | jq '.item.credentials[0].secret.decoded.username'
	@read -n1
	vault list sys/leases/lookup/hashicups/database/creds/boundary

postgres-products:
	boundary connect postgres \
		-target-id $(shell cd boundary && terraform output -raw boundary_target_postgres) \
		-dbname products

configure-db:
	curl -s https://raw.githubusercontent.com/hashicorp-demoapp/product-api-go/v0.0.19/database/products.sql --output products.sql
	@read -n1
	boundary connect postgres \
		-target-id $(shell cd boundary && terraform output -raw boundary_target_postgres) \
		-dbname products -- -f products.sql

clean-leases:
	vault lease revoke -f -prefix boundary/aws/creds/ecs
	vault lease revoke -f -prefix hashicups/database/creds

clean:
	vault lease revoke -f -prefix terraform/aws/creds
	rm -rf secrets/