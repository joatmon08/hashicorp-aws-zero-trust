resource "hcp_hvn" "hvn" {
  hvn_id         = var.name
  cloud_provider = "aws"
  region         = var.hcp_region
  cidr_block     = var.hcp_network_cidr_block
}

resource "hcp_consul_cluster" "consul" {
  hvn_id          = hcp_hvn.hvn.hvn_id
  cluster_id      = var.name
  tier            = "development"
  datacenter      = "dc1"
  public_endpoint = true
}

resource "hcp_consul_cluster_root_token" "cluster" {
  cluster_id = hcp_consul_cluster.consul.id
}

resource "hcp_vault_cluster" "vault" {
  cluster_id      = var.name
  hvn_id          = hcp_hvn.hvn.hvn_id
  public_endpoint = true
}

resource "hcp_vault_cluster_admin_token" "cluster" {
  cluster_id = hcp_vault_cluster.vault.cluster_id
}
