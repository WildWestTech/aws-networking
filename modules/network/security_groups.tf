# ports:     0 = all
# protocol: -1 = all
#===========================================================
# Security Group to Allow All Internal Traffic (VPC: main)
#===========================================================
resource "aws_default_security_group" "main-default" {
  vpc_id = aws_vpc.main.id

    ingress {
    protocol  = -1
    self      = true
    from_port = 0
    to_port   = 0
    description = "allow local traffic"
  }

#     ingress {
#     protocol  = -1
#     from_port = 0
#     to_port   = 0
#     cidr_blocks = [data.aws_vpc.openvpn.cidr_block]
#     description = "allow peer traffic from openvpn"
#   }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    name = "main-default"
    env  = "${var.env}"
  }
}


#===========================================================
# Security Group to Allow All Internal Traffic (VPC: openvpn)
#===========================================================
# resource "aws_default_security_group" "openvpn-default" {
#   vpc_id = data.aws_vpc.openvpn.id

#     ingress {
#     protocol  = -1
#     self      = true
#     from_port = 0
#     to_port   = 0
#     description = "allow local traffic"
#   }

#     ingress {
#     protocol  = -1
#     from_port = 0
#     to_port   = 0
#     cidr_blocks = [aws_vpc.main.cidr_block]
#     description = "allow peer traffic from main"
#   }

#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   tags = {
#     name = "main-default"
#   }
# }
#===========================================================
# Database (Postgres) Security Group
# Attention to Postgres Port
#===========================================================
resource "aws_security_group" "postgres" {
  name        = "postgres_sg"
  description = "PostgreSQL Security Group"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    security_groups = [aws_default_security_group.main-default.id]
    description = "allow local traffic"
  }

#     ingress {
#     from_port   = 5432
#     to_port     = 5432
#     protocol    = "tcp"
#     security_groups = [data.aws_security_group.openvpn.id]
#     description = "allow openvpn traffic"
#   }
}

#===========================================================
# Database (Aurora Postgres) Security Group
# Attention to Aurora PG Port
# We could consolidate some of the database secrity groups, especially when multiple databases use the same ports (5432)
# But we could have SQL Server, Redshift, etc.  Would we just add more ingress ports?
# It's not that hard to just give each their own sg.
#===========================================================
resource "aws_security_group" "aurora_pg" {
  name        = "aurora_pg_sg"
  description = "Aurora PG Security Group"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    security_groups = [aws_default_security_group.main-default.id]
    description = "allow local traffic"
  }

#     ingress {
#     from_port   = 5432
#     to_port     = 5432
#     protocol    = "tcp"
#     security_groups = [data.aws_security_group.openvpn.id]
#     description = "allow openvpn traffic"
#   }
}