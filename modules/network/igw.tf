#===========================================================
# Internet gateway - allows instances with public IPs to access the internet
#===========================================================
resource "aws_internet_gateway" "igw" {
    vpc_id = aws_vpc.main.id
    tags = {
        Name    = "IGW"
        VPC     = "main"
        env     = "${var.env}"
    }
}