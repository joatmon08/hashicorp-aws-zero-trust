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
	mkdir -p secrets/
	vault read hashicups/database/creds/boundary -format=json > secrets/boundary.json
	vault read hashicups/database/creds/product -format=json > secrets/product.json

postgres-products: boundary-auth-dev
	@PGPASSWORD=$(shell cat secrets/product.json | jq -r .data.password) \
		boundary connect postgres -username=$(shell cat secrets/product.json | jq -r .data.username) \
		-addr $(shell cd infrastructure && terraform output -raw boundary_endpoint) \
		-target-id $(shell cd boundary && terraform output -raw boundary_target_postgres) -- -d products

configure-db: boundary-auth-dev
	@PGPASSWORD=$(shell cat secrets/boundary.json | jq -r .data.password) \
		boundary connect postgres -username=$(shell cat secrets/boundary.json | jq -r .data.username) \
		-addr $(shell cd infrastructure && terraform output -raw boundary_endpoint) \
		-target-id $(shell cd boundary && terraform output -raw boundary_target_postgres) -- -d products -f database/products.sql

clean:
	vault lease revoke -f -prefix hashicups/database/creds
	rm -rf secrets/