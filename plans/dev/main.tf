#===========================================================
# helpful commands
# terraform init
# terraform plan
# terraform apply
# terraform force-unlock <lock-id>
#===========================================================
# telling terraform where and how to work with the statefile
# we're storing it in an s3 bucket in aws
#===========================================================
terraform {
    backend "s3" {
        bucket          = "wildwesttech-terraform-backend-state-dev"
        key             = "aws-networking-dev/terraform.tfstate"
        region          = "us-east-1"
        dynamodb_table  = "terraform-state-locking"
        encrypt         = true
        profile         = "251863357540_AdministratorAccess"
    }

}
provider "aws" {
    profile = "${var.profile}"
    region  = "${var.region}"
}

provider "aws" {
    alias     = "peer"
    region    = "us-east-1"
    profile   = "785888383526_AdministratorAccess"
}

module "network" {
    source          = "../../modules/network"
    second_octet    = "${var.second_octet}"
    env             = "${var.env}"
}