#===============================================================
# Note: Because NAT Gateways are not free, I will likely move this file to "inactive" between sessions.
# In order to minimize commenting out/moving too many files, I'll include all relevant info in this file.
# B/C nat gateways are not free, I will be using them sparingly.
# Currently testing MWAA which requires subnets in 2 AZs, so I need 2 NAt Gateways.  
# I could keep things more symmetric/complete and put a third in my remaining AZ, but I'd rather save the money for now.
#===============================================================

#=======================================================
# Nat Gateway and Routing for 1A
#=======================================================
resource "aws_eip" "nat-gateway-1A" {
  vpc      = true
  tags     = {
    name     = "nat-gateway-1A"
  }
}

resource "aws_nat_gateway" "nat-gateway-1A" {
  allocation_id = aws_eip.nat-gateway-1A.id
  subnet_id     = aws_subnet.Public-1A.id
  tags = {
    Name = "gw NAT 1A"
  }
  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.igw]
}

resource "aws_route" "nat_gateway_route_1A" {
  route_table_id          = aws_route_table.Private-RT-1A.id
  destination_cidr_block  = "0.0.0.0/0"
  nat_gateway_id          = aws_nat_gateway.nat-gateway-1A.id
}