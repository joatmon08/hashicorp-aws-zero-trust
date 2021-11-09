boundary-auth-ops:
	@boundary authenticate password -login-name=jeff \
		-addr $(shell cd infrastructure && terraform output -raw boundary_endpoint) \
		-password $(shell cd boundary && terraform output -raw boundary_operations_password) \
		-auth-method-id=$(shell cd boundary && terraform output -raw boundary_auth_method_id)

boundary-auth-dev:
	@boundary authenticate password -login-name=rosemary \
		-addr $(shell cd infrastructure && terraform output -raw boundary_endpoint) \
		-password $(shell cd boundary && terraform output -raw boundary_products_password) \
		-auth-method-id=$(shell cd boundary && terraform output -raw boundary_auth_method_id)

ssh-ecs: boundary-auth-ops
	boundary connect ssh -username=ec2-user \
		-addr $(shell cd infrastructure && terraform output -raw boundary_endpoint) \
		-target-id $(shell cd boundary && terraform output -raw boundary_target_ecs) -- -i ~/.ssh/aws/rosemary-us-east-1.pem

vault-db:
	@mkdir -p secrets/
	vault read hashicups/database/creds/product -format=json > secrets/product.json

vault-aws:
	@mkdir -p secrets/
	vault read terraform/aws/creds/hashicups -format=json > secrets/aws.json
	@read -n1
	cat secrets/aws.json | jq .data.access_key

postgres-creds:
	boundary targets authorize-session \
		-id $(shell cd boundary && terraform output -raw boundary_target_postgres) \
		-format json > secrets/boundary.json

postgres-products: boundary-auth-dev
	boundary connect postgres \
		-target-id $(shell cd boundary && terraform output -raw boundary_target_postgres) \
		-dbname products

configure-db: boundary-auth-dev
	boundary connect postgres \
		-target-id $(shell cd boundary && terraform output -raw boundary_target_postgres) \
		-dbname products -- -f database/products.sql

clean:
	vault lease revoke -f -prefix hashicups/database/creds
	vault lease revoke -f -prefix terraform/aws/creds
	rm -rf secrets/