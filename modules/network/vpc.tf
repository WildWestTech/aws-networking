#create a vpc
#this will also create:
#   1 main route table
#   1 nacl
#   1 security group
resource "aws_vpc" "main" {
    cidr_block = "10.${var.second_octet}.0.0/16"
    instance_tenancy = "default"
    enable_dns_hostnames = true
   
    tags = {
        Name = "main"
        env  = "${var.env}"
        for-use-with-amazon-emr-managed-policies = true
    }
}