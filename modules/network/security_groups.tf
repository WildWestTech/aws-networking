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

  ingress {
    protocol  = -1
    from_port = 0
    to_port   = 0
    cidr_blocks = [var.openvpn_cidr_block]
    description = "allow peer traffic from openvpn"
  }

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
# Database (Postgres) Security Group
# Attention to Postgres Port
#===========================================================
resource "aws_security_group" "databases" {
  name        = "database_security_group"
  description = "Security Group For Databases"
  vpc_id      = aws_vpc.main.id
}

resource "aws_security_group_rule" "databases-pg-main" {
  type                      = "ingress"
  from_port                 = 5432
  to_port                   = 5432
  protocol                  = "tcp"
  security_group_id         = aws_security_group.databases.id
  source_security_group_id  = aws_default_security_group.main-default.id
  description               = "allow local traffic for pg"
  depends_on = [
    aws_security_group.databases
  ]
}

resource "aws_security_group_rule" "databases-pg-openvpn" {
  type                      = "ingress"
  from_port                 = 5432
  to_port                   = 5432
  protocol                  = "tcp"
  security_group_id         = aws_security_group.databases.id
  source_security_group_id  = var.openvpn_sg
  description               = "allow local traffic for pg"
  depends_on = [
    aws_security_group.databases
  ]
}
#===========================================================
# EMR Studio: Engine - Allow Traffic From Workspace
#===========================================================
resource "aws_security_group" "emr_engine_security_group" {
  name        = "emr_engine_security_group"
  description = "allow traffic from workspace"
  vpc_id      = aws_vpc.main.id
  tags        = {
    for-use-with-amazon-emr-managed-policies = true
  }
}

resource "aws_security_group_rule" "emr_engine_security_group_egress" {
  type                      = "egress"
  from_port                 = 0
  to_port                   = 0
  protocol                  = -1
  security_group_id         = aws_security_group.emr_engine_security_group.id
  cidr_blocks               = ["0.0.0.0/0"]
  description               = "allow all egress traffic"
  depends_on = [
    aws_security_group.emr_engine_security_group,
    aws_security_group.emr_workspace_security_group
  ]
}

resource "aws_security_group_rule" "emr_engine_security_group" {
  type                      = "ingress"
  from_port                 = 18888
  to_port                   = 18888
  protocol                  = "tcp"
  security_group_id         = aws_security_group.emr_engine_security_group.id
  source_security_group_id  = aws_security_group.emr_workspace_security_group.id
  description               = "allow traffic from workspace"
  depends_on = [
    aws_security_group.emr_engine_security_group,
    aws_security_group.emr_workspace_security_group
  ]
}

#===========================================================
# EMR Studio: Workspace - Allow Traffic To Engine and To Git
#===========================================================
resource "aws_security_group" "emr_workspace_security_group" {
  name        = "emr_workspace_security_group"
  description = "allow all egress traffic"
  vpc_id      = aws_vpc.main.id
  tags        = {
    for-use-with-amazon-emr-managed-policies = true
  }
}

resource "aws_security_group_rule" "emr_workspace_security_group_egress" {
  type                      = "egress"
  from_port                 = 0
  to_port                   = 0
  protocol                  = -1
  security_group_id         = aws_security_group.emr_workspace_security_group.id
  cidr_blocks               = ["0.0.0.0/0"]
  description               = "allow traffic from workspace"
  depends_on = [
    aws_security_group.emr_engine_security_group,
    aws_security_group.emr_workspace_security_group
  ]
}

resource "aws_security_group_rule" "emr_workspace_security_group_18888" {
  type                      = "egress"
  from_port                 = 18888
  to_port                   = 18888
  protocol                  = "tcp"
  security_group_id         = aws_security_group.emr_workspace_security_group.id
  source_security_group_id  = aws_security_group.emr_engine_security_group.id
  description               = "allow traffic to engine"
  depends_on = [
    aws_security_group.emr_engine_security_group,
    aws_security_group.emr_workspace_security_group
  ]
}

resource "aws_security_group_rule" "emr_workspace_security_group_443" {
  type                      = "egress"
  from_port                 = 443
  to_port                   = 443
  protocol                  = "tcp"
  cidr_blocks               = ["0.0.0.0/0"] 
  security_group_id         = aws_security_group.emr_workspace_security_group.id
  description               = "allow 443 traffic for git"
  depends_on = [
    aws_security_group.emr_engine_security_group,
    aws_security_group.emr_workspace_security_group
  ]
}


#===========================================================
# MWAA
# https://docs.aws.amazon.com/mwaa/latest/userguide/networking-about.html
#===========================================================
resource "aws_security_group" "mwaa" {
  name = "mwaa_security_group"
  vpc_id      = aws_vpc.main.id
  tags = {
    Name = "mwaa-sg"
  }
}

resource "aws_security_group_rule" "mwaa_self_referencing" {
  type                      = "ingress"
  from_port                 = 0
  to_port                   = 0
  protocol                  = -1
  self                      = true
  description               = "self referencing"
  security_group_id         = aws_security_group.mwaa.id 
  depends_on                = [aws_security_group.mwaa]
}

resource "aws_security_group_rule" "mwaa_outbound" {
  type                      = "egress"
  from_port                 = 0
  to_port                   = 0
  protocol                  = -1
  cidr_blocks               = ["0.0.0.0/0"]
  description               = "allow outbound"
  security_group_id         = aws_security_group.mwaa.id
  depends_on                = [aws_security_group.mwaa]
}

resource "aws_security_group_rule" "mwaa_tcp" {
  type                      = "ingress"
  from_port                 = 443
  to_port                   = 443
  protocol                  = "tcp"
  self                      = true
  description               = "allow tcp"
  security_group_id         = aws_security_group.mwaa.id
  depends_on                = [aws_security_group.mwaa]
}

resource "aws_security_group_rule" "mwaa_pg" {
  type                      = "ingress"
  from_port                 = 5432
  to_port                   = 5432
  protocol                  = "tcp"
  self                      = true
  description               = "mwaa postgres metadata"
  security_group_id         = aws_security_group.mwaa.id
  depends_on                = [aws_security_group.mwaa]
}

#===========================================================
# AirFlow EC2
#===========================================================
resource "aws_security_group" "airflow_ec2_security_group" {
  name = "airflow_ec2_security_group"
  vpc_id      = aws_vpc.main.id
  tags = {
    Name = "airflow_ec2_security_group"
  }
}

resource "aws_security_group_rule" "airflow_ec2_security_group_outbound" {
  type                      = "egress"
  from_port                 = 0
  to_port                   = 0
  protocol                  = -1
  cidr_blocks               = ["0.0.0.0/0"]
  description               = "allow outbound"
  security_group_id         = aws_security_group.airflow_ec2_security_group.id
  depends_on                = [aws_security_group.airflow_ec2_security_group]
}

resource "aws_security_group_rule" "airflow-openvpn" {
  type                      = "ingress"
  from_port                 = 0
  to_port                   = 0
  protocol                  = -1
  security_group_id         = aws_security_group.airflow_ec2_security_group.id
  source_security_group_id  = var.openvpn_sg
  description               = "allow vpn traffic"
  depends_on                = [aws_security_group.airflow_ec2_security_group]
}