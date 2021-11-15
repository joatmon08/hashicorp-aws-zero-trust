AUTH_METHOD_ID:=$(shell cd boundary && terraform output -raw boundary_auth_method_id)

vault-aws:
	@mkdir -p secrets/
	vault read terraform/aws/creds/hashicups -format=json > secrets/aws.json
	@read -n1
	cat secrets/aws.json | jq .data.access_key
	@read -n1
	vault list sys/leases/lookup/terraform/aws/creds/hashicups

vault-db:
	@mkdir -p secrets/
	vault read hashicups/database/creds/product -format=json > secrets/product.json
	@read -n1
	cat secrets/product.json | jq .data.username
	@read -n1
	vault list sys/leases/lookup/hashicups/database/creds/product

boundary-auth-ops:
	@echo 'boundary authenticate password -login-name=jeff -password REDACTED -auth-method-id=$(AUTH_METHOD_ID)'
	@boundary authenticate password -login-name=jeff \
		-password $(shell cd boundary && terraform output -raw boundary_operations_password) \
		-auth-method-id=$(AUTH_METHOD_ID)

boundary-auth-dev:
	@echo 'boundary authenticate password -login-name=rosemary -password REDACTED -auth-method-id=$(AUTH_METHOD_ID)'
	@boundary authenticate password -login-name=rosemary \
		-password $(shell cd boundary && terraform output -raw boundary_products_password) \
		-auth-method-id=$(shell cd boundary && terraform output -raw boundary_auth_method_id)

ssh-ecs: boundary-auth-ops
	@read -n1
	boundary connect ssh -username=ec2-user \
		-target-id $(shell cd boundary && terraform output -raw boundary_target_ecs) -- -i ~/.ssh/aws/rosemary-us-east-1.pem

postgres-creds:
	boundary targets authorize-session \
		-id $(shell cd boundary && terraform output -raw boundary_target_postgres) \
		-format json > secrets/boundary.json
	@read -n1
	cat secrets/boundary.json | jq .data.username
	@read -n1
	vault list sys/leases/lookup/hashicups/database/creds/boundary

postgres-products:
	boundary connect postgres \
		-target-id $(shell cd boundary && terraform output -raw boundary_target_postgres) \
		-dbname products

configure-db: boundary-auth-dev
	@read -n1
	boundary connect postgres \
		-target-id $(shell cd boundary && terraform output -raw boundary_target_postgres) \
		-dbname products -- -f database/products.sql

clean:
	vault lease revoke -f -prefix hashicups/database/creds
	vault lease revoke -f -prefix terraform/aws/creds
	rm -rf secrets/