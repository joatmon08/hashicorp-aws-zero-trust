boundary-auth-ops:
	export BOUNDARY_ADDRESS=$(shell cd infrastructure && terraform output -raw boundary_endpoint)
	@boundary authenticate password -login-name=jeff \
		-password $(shell cd boundary && terraform output -raw boundary_operations_password) \
		-auth-method-id=$(shell cd boundary && terraform output -raw boundary_auth_method_id)

boundary-auth-dev:
	export BOUNDARY_ADDRESS=$(shell cd infrastructure && terraform output -raw boundary_endpoint)
	@boundary authenticate password -login-name=rosemary \
		-password $(shell cd boundary && terraform output -raw boundary_products_password) \
		-auth-method-id=$(shell cd boundary && terraform output -raw boundary_auth_method_id)

ssh-ecs: boundary-auth-ops
	boundary connect ssh -username=ec2-user -target-id \
		$(shell cd boundary && terraform output -raw boundary_target_ecs) -- -i ~/.ssh/aws/rosemary-us-east-1.pem

postgres-products: boundary-auth-dev
	boundary connect postgres -username=postgres -target-id \
		$(shell cd boundary && terraform output -raw boundary_target_postgres) -- -d products

configure-db: boundary-auth-dev
	boundary connect postgres -username=postgres -target-id \
		$(shell cd boundary && terraform output -raw boundary_target_postgres) -- -d products -f database/products.sql