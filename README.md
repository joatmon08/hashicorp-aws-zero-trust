# HashiCorp Zero Trust Foundations on AWS

This example demonstrates how HashiCorp tools run on AWS, including:

1. Boundary
1. HashiCorp Cloud Platform Vault
1. HashiCorp Cloud Platform Consul
1. Terraform Cloud

It uses the following AWS services:

1. Amazon ECS
1. AWS KMS

## Usage

To run this example, you need Terraform Cloud to set up a series of workspaces.
The workspaces need to be set up as follows, with the appropriate working directory, secrets,
and remote workspace sharing.

| Workspace Name | Working Directory for VCS | Variables | Remote State Sharing |
| ----------- | ----------- | ----------- | ----------- |
| hcp      | `hcp/` | name, trusted_role_arn, bootstrap AWS access keys, HCP credentials | infrastructure, consul, boundary, vault-aws |
| vault-aws      | `vault/aws/` | name, AWS access keys (for AWS secrets engine) |  |
| infrastructure      | `infrastructure/` | name, client_cidr_block, HCP service principal credentials, database_password, boundary_database_password, key_pair_name. [FROM VAULT] AWS access keys | boundary, apps, vault-products |
| vault-products | `vault/products/` | name, HCP service principal credentials | boundary |
| boundary      | `boundary/` | name. [FROM VAULT] db_password, db_username, AWS access keys | |
| apps      | `apps/` | name, client_cidr_block. [FROM VAULT] db_password, db_username, AWS access keys | |

You need to run plan and apply for each workspace in the order indicated.

## AWS secrets engine for Vault

Imagine you want to issue AWS access keys for each group that runs Terraform. You can use
Vault's AWS secrets engine to generate access keys for each group.

For example, you set up an initial AWS access and secret key for Vault to issue new
credentials. The AWS access and secret key assume a role with sufficient permissions
for Terraform to configure infrastructure on AWS.

1. Run `terraform apply` for the `hcp` workspace. It creates:
    - HCP network
    - HCP Vault cluster
    - HCP Consul cluster
    - AWS IAM Role for Terraform

1. Sets the Vault address, token, and namespace for you to get
   a new set of AWS access keys from Vault in your CLI.
   ```shell
   source set.sh
   ```

1. Next, generate a set of AWS access keys for the Vault secrets engine. These should be
   different than the ones you used to bootstrap HCP and the AWS IAM role!

1. Add the new AWS access keys to `vault-aws` workspace.

1. Run `terraform apply` for the `vault-aws` workspace. It creates:
    - Path for AWS secrets engine in Vault at `terraform/aws`
    - Role for your team (e.g., `hashicups`)

1. Run `make vault-aws`. This retrieves a new set of AWS access keys from Vault via
   the secrets engine and saves it to the `secrets/` directory locally.
   ```shell
   make vault-aws
   ```

1. Use the AWS access and secret keys from `secrets/aws.json` and add them to the
   `infrastructure`, `boundary`, and `apps` workspaces.

1. Run `terraform apply` for the `infrastructure` workspace. It creates:
    - AWS VPC and peers to HCP network
    - HashiCups database (PostgreSQL)
    - Boundary cluster (1 worker, 1 controller, database)
    - Amazon ECS cluster (1 EC2 container instance)

## Secrets for the Products API

We need to generate a few things for the products API (and Boundary).

- Database secrets engine for HashiCups data (used by `product-api` and Boundary)
- AWS IAM Auth Method for `vault-agent` in HashiCups `product-api`

To configure this, you need to add HCP service credentials with the Vault address, token, and
namespace to `vault-products`.

You have two identities that need to access the application's database:

1. Application (`product-api`) to __read from__ the database
1. Human user (`ops` or `dev` team) to __update__ the database using Boundary

Configure the following.

1. Run `terraform apply` for the `vault-products` workspace. It creates:
    - Path for database credentials in Vault at `hashicups/database`
    - Role for the application that will access it (e.g., `product`)
    - Role for Boundary user to access it (e.g., `boundary`)
## Configuring Boundary

Boundary needs a set of organizations and projects. You have two projects:

1. `core_infra`: ECS container instance. Allow `ops` team to SSH into it.
1. `product_infra`: Application database. Allow `ops` or `dev` team to configure it.

Configure the following.

1. Run `terraform apply` for the `boundary` workspace. It creates:
    - Two projects, one for `core_infra` and the other for `product_infra`.
    - Three users, `jeff` for the `ops` team, `rosemary` for the `dev` team,
      and `taylor` for the `security` team.
    - Two targets:
        - ECS container instance (not yet added)
        - Application database, brokered by Vault credentials

### Dynamic Host Catalog

1. Run `source set.sh` to set your Boundary address.

1. Run `make boundary-host-catalog` to configure the host catalog for the ECS container instances.
   This uses dynamic host catalog plugins in Boundary to auto-discover AWS EC2 instances with the cluster
   tag.

1. You can also SSH into the ECS container instance as the `ops` team. Run `make ssh-ecs`.

### Vault Credentials Brokering

1. Boundary uses Vault as a credentials store to retrieve a new set of database credentials!
   Run `make configure-db` to log into Boundary as the `dev` team and configure the database -
   all without knowing the username or password!

## Consul intentions

You may need to control network policy between services on ECS and other services
registered to Consul. You can use intentions to secure service-to-service communication.

1. Run `terraform apply` for the `apps` workspace. It creates three ECS services:
    1. `frontend` (Fargate launch type)
    1. `public-api` (Fargate launch type)
    1. `product-api` (EC2 launch type)

1. Run `terraform apply` for the `vault-products` workspace. It adds:
    - AWS IAM authentication method for ECS task to authenticate to vault

1. Run `make products` to mark the `product-api` to be recreated.

1. Run `terraform apply` for the `apps` workspace. It should redeploy the `product-api`.

1. Try to access the frontend via the ALB. You might get an error! We need to enable
   traffic between the services registered to Consul.

1. Try to access the frontend via the ALB. You'll get a `Packer Spiced Latte`!