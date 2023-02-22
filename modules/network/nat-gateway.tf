#===============================================================
# Note: Because NAT Gateways are not free, I will likely move this file to "inactive" between sessions.
# In order to minimize commenting out/moving too many files, I'll include all relevant info in this file.
#===============================================================

resource "aws_eip" "nat-gateway" {
  vpc      = true
}

resource "aws_nat_gateway" "nat-gateway-1A" {
  allocation_id = aws_eip.nat-gateway.id
  subnet_id     = aws_subnet.Public-1A.id

  tags = {
    Name = "gw NAT"
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.igw]
}

resource "aws_route" "nat_gateway_route" {
  route_table_id = aws_route_table.Private-RT.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.nat-gateway-1A.id
}