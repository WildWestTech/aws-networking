#================================================================
# Cross-Account VPC Peering Connection for VPN
# Note: apply main.tf prior to applying vpc_peering.tf (I simply move this file in/out of the "inactive" folder)
#================================================================
data "aws_caller_identity" "peer" {
  provider = aws.peer
}

data "aws_vpc" "main" {
  filter {
    name = "tag:Name"
    values = ["main"]
  }
}

data "aws_vpc" "peer" {
  provider = aws.peer

  filter {
    name   = "tag:Name"
    values = ["openvpn-vpc"]
  }
}

# Requester's side of the connection.
resource "aws_vpc_peering_connection" "peer" {
  vpc_id        = data.aws_vpc.main.id
  peer_vpc_id   = data.aws_vpc.peer.id
  peer_owner_id = data.aws_caller_identity.peer.account_id
  peer_region   = "${var.region}"
  auto_accept   = false

  tags = {
    Side = "Requester"
  }
}

# Accepter's side of the connection.
resource "aws_vpc_peering_connection_accepter" "peer" {
  provider                  = aws.peer
  vpc_peering_connection_id = aws_vpc_peering_connection.peer.id
  auto_accept               = true

  tags = {
    Side = "Accepter"
  }
}

#===========================================================
# VPC Peering Route
# We have Public & Private Route Tables in Each Peer: 2x2
# In our main VPC:
# - add route to public rt, w/dest of peer's cidr, targeting peer connection
# - add route to private rt, w/dest of peer's cidr, targeting peer connection
# Mirror this in peer vpc
#===========================================================
data "aws_route_table" "Public-RT" {
  filter {
    name   = "tag:Name"
    values = ["Public-RT"]
  }
  vpc_id = data.aws_vpc.main.id
}

data "aws_route_table" "Private-RT" {
  filter {
    name   = "tag:Name"
    values = ["Private-RT"]
  }
  vpc_id = data.aws_vpc.main.id
}

resource "aws_route" "peer_route_to_openvpn-Public-RT" {
  route_table_id = data.aws_route_table.Public-RT.id
  destination_cidr_block = data.aws_vpc.peer.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.peer.id
}

resource "aws_route" "peer_route_to_openvpn-Private-RT" {
  route_table_id = data.aws_route_table.Private-RT.id
  destination_cidr_block = data.aws_vpc.peer.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.peer.id
}

#====================================================
data "aws_route_table" "Openvpn-Public-RT" {
provider = aws.peer
  filter {
    name   = "tag:Name"
    values = ["OpenVPN-Public-RT"]
  }
  vpc_id = data.aws_vpc.peer.id
}

data "aws_route_table" "Openvpn-Private-RT" {
provider = aws.peer
  filter {
    name   = "tag:Name"
    values = ["OpenVPN-Private-RT"]
  }
  vpc_id = data.aws_vpc.peer.id
}

resource "aws_route" "openvpn_route_to_peer-Public-RT" {
  provider = aws.peer
  route_table_id = data.aws_route_table.Openvpn-Public-RT.id
  destination_cidr_block = data.aws_vpc.main.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection_accepter.peer.id
}

resource "aws_route" "openvpn_route_to_peer-Private-RT" {
  provider = aws.peer
  route_table_id = data.aws_route_table.Openvpn-Private-RT.id
  destination_cidr_block = data.aws_vpc.main.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection_accepter.peer.id
}