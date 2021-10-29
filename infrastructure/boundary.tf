module "boundary" {
  depends_on                   = [module.vpc]
  source                       = "github.com/joatmon08/terraform-aws-boundary"
  vpc_id                       = module.vpc.vpc_id
  vpc_cidr_block               = module.vpc.vpc_cidr_block
  public_subnet_ids            = module.vpc.public_subnets
  private_subnet_ids           = module.vpc.database_subnets
  name                         = "boundary-${var.name}"
  key_pair_name                = var.key_pair_name
  allow_cidr_blocks_to_workers = [var.client_cidr_block]
  allow_cidr_blocks_to_api     = ["0.0.0.0/0"] # Allow TFC to configure
  boundary_db_password         = var.boundary_database_password
}
