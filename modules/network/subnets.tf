#=================================================================
# us-east-1a
#=================================================================
resource "aws_subnet" "Public-1A" {
    vpc_id = aws_vpc.main.id
    cidr_block = "10.${var.second_octet}.1.0/24"
    availability_zone = "us-east-1a"
    map_public_ip_on_launch = true
    tags = {
        Name = "Public-1A"
        env = "${var.env}"
    }
}

resource "aws_subnet" "Private-1A" {
    vpc_id = aws_vpc.main.id
    cidr_block = "10.${var.second_octet}.2.0/24"
    availability_zone = "us-east-1a"
    tags = {
        Name = "Private-1A"
        env = "${var.env}"
    }
}
#=================================================================
# us-east-1b
#=================================================================
resource "aws_subnet" "Public-1B" {
    vpc_id = aws_vpc.main.id
    cidr_block = "10.${var.second_octet}.3.0/24"
    availability_zone = "us-east-1b"
    map_public_ip_on_launch = true
    tags = {
        Name = "Public-1B"
        env = "${var.env}"
    }
}

resource "aws_subnet" "Private-1B" {
    vpc_id = aws_vpc.main.id
    cidr_block = "10.${var.second_octet}.4.0/24"
    availability_zone = "us-east-1b"
    tags = {
        Name = "Private-1B"
        env = "${var.env}"
    }
}
#=================================================================
# us-east-1c
#=================================================================
resource "aws_subnet" "Public-1C" {
    vpc_id = aws_vpc.main.id
    cidr_block = "10.${var.second_octet}.5.0/24"
    availability_zone = "us-east-1c"
    map_public_ip_on_launch = true
    tags = {
        Name = "Public-1C"
        env = "${var.env}"
    }
}

resource "aws_subnet" "Private-1C" {
    vpc_id = aws_vpc.main.id
    cidr_block = "10.${var.second_octet}.6.0/24"
    availability_zone = "us-east-1c"
    tags = {
        Name = "Private-1C"
        env = "${var.env}"
    }
}