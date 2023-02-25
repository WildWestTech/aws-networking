variable env {
    type = string
}

variable second_octet {
    type = string
}

variable openvpn_cidr_block {
    type = string
}

variable openvpn_sg {
    type = string
}

variable region {
    type = string
    default = "us-east-1"
}

variable "nat-gateway-az-list" {
   type= list
   default= [
    "1A",
    "1B"
    ]
}