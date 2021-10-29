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

ssh-operations: boundary-auth-ops
	boundary connect ssh -username=ec2-user -target-id \
		$(shell cd boundary && terraform output -raw boundary_target_ecs) -- -i ~/.ssh/aws/rosemary-us-east-1.pem

ssh-products: boundary-auth-dev
	boundary connect ssh -username=ec2-user -target-id \
		$(shell cd boundary && terraform output -raw boundary_target_ecs) -- -i boundary-deployment/bin/id_rsa

postgres-operations: boundary-auth-ops
	boundary connect postgres -username=postgres -target-id \
		$(shell cd boundary && terraform output -raw boundary_target_postgres)

postgres-products: boundary-auth-dev
	boundary connect postgres -username=postgres -target-id \
		$(shell cd boundary && terraform output -raw boundary_target_postgres) -- -d products