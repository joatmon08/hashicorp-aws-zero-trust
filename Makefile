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

postgres-products: boundary-auth-dev
	boundary connect postgres -username=postgres \
		-addr $(shell cd infrastructure && terraform output -raw boundary_endpoint) \
		-target-id $(shell cd boundary && terraform output -raw boundary_target_postgres) -- -d products

configure-db: boundary-auth-dev
	boundary connect postgres -username=postgres \
		-addr $(shell cd infrastructure && terraform output -raw boundary_endpoint) \
		-target-id $(shell cd boundary && terraform output -raw boundary_target_postgres) -- -d products -f database/products.sql