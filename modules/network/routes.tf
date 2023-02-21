# Create a route table for the private subnets
# Default destination 10.x.0.0/16 targets local
# After we explicitly associate the private subnets with this route table, 
# Remaining public subnets will continue to implicitly associate with the main route table

#===========================================================
# Route Tables
#===========================================================
# Private Route Table
# Default local route 10.x.0.0/16
resource "aws_route_table" "Private-RT" {
    vpc_id = aws_vpc.main.id
    tags = {
        Name = "Private-RT"
    }
}

# Public Route Table
# Default local route 10.x.0.0/16
resource "aws_route_table" "Public-RT" {
    vpc_id = aws_vpc.main.id
    tags = {
        Name = "Public-RT"
    }
}
#===========================================================
# Private Route Table Association
#===========================================================
# Explicitly associate the private route table with subnet Private-1A
resource "aws_route_table_association" "Private-1A" {
    subnet_id = aws_subnet.Private-1A.id
    route_table_id = aws_route_table.Private-RT.id
}

# Explicitly associate the private route table with subnet Private-1B
resource "aws_route_table_association" "Private-1B" {
    subnet_id = aws_subnet.Private-1B.id
    route_table_id = aws_route_table.Private-RT.id
}

# Explicitly associate the private route table with subnet Private-1C
resource "aws_route_table_association" "Private-1C" {
    subnet_id = aws_subnet.Private-1C.id
    route_table_id = aws_route_table.Private-RT.id
}
#===========================================================
# Public Route Table Association
#===========================================================
# Explicitly associate the public route table with subnet Public-1A
resource "aws_route_table_association" "Public-1A" {
    subnet_id = aws_subnet.Public-1A.id
    route_table_id = aws_route_table.Public-RT.id
}

# Explicitly associate the public route table with subnet Public-1B
resource "aws_route_table_association" "Public-1B" {
    subnet_id = aws_subnet.Public-1B.id
    route_table_id = aws_route_table.Public-RT.id
}

# Explicitly associate the public route table with subnet Public-1C
resource "aws_route_table_association" "Public-1C" {
    subnet_id = aws_subnet.Public-1C.id
    route_table_id = aws_route_table.Public-RT.id
}

#===========================================================
# IGW Routing: Public Subnets -> IGW
#===========================================================
# Routes Internet Traffic Through Internet Gateway
resource "aws_route" "route_to_igw" {
  route_table_id = aws_route_table.Public-RT.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.igw.id
}