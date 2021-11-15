locals {
  route_table_ids = concat(module.vpc.private_route_table_ids, module.vpc.public_route_table_ids)
}

resource "hcp_aws_network_peering" "peer" {
  hvn_id          = local.hvn_id
  peer_vpc_id     = module.vpc.vpc_id
  peer_account_id = module.vpc.vpc_owner_id
  peer_vpc_region = local.region
  peering_id      = local.hvn_id
}

resource "aws_vpc_peering_connection_accepter" "hvn" {
  vpc_peering_connection_id = hcp_aws_network_peering.peer.provider_peering_id
  auto_accept               = true
}

resource "aws_route" "hvn" {
  count                     = length(local.route_table_ids)
  route_table_id            = local.route_table_ids[count.index]
  destination_cidr_block    = local.hvn_cidr_block
  vpc_peering_connection_id = hcp_aws_network_peering.peer.provider_peering_id
}

resource "hcp_hvn_route" "hvn" {
  hvn_link         = local.hvn_self_link
  hvn_route_id     = "${local.hvn_id}-to-vpc"
  destination_cidr = module.vpc.vpc_cidr_block
  target_link      = hcp_aws_network_peering.peer.self_link
}